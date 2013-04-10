module Konosys
  module Actions
    class GradesDetailed < Konosys::Action

      class GradeDetailedEntity < APISmith::Smash
        # Grade's program, eg: HEI4 Tronc Commun annualisé
        property :program
        # Grade's course, eg: Anglais
        property :course
        # Grade's name, eg: DS1 Anglais
        property :name
        # Grade's date, eg: 16/01/2012
        property :date, :transformer => lambda { |t| Date.parse t }
        # Grade's type, eg: Partiel / Devoir Surveillé
        property :type
        # Grade's weight, eg: 20
        property :weight, :transformer => :to_f
        # Grade's mark, eg: 15.0
        property :mark, :transformer => :to_f
        # Grade unknown?, eg: true when grade is 'NI', false otherwise
        property :unknown
      end

      GRADES_DETAILS_URL = 'http://e-campus.hei.fr/KonosysProd/interfaces/interface_impression_courriers_etudiant_portail_etudiant.aspx?id_inscriptionsessionprogramme='

      def fetch
        login

        # Default parser when the fetched page isn't as expected (ie: anything but a web page)
        @browser.pluggable_parser.default = Mechanize::Download

        # Fetch the file in several steps
        page = @browser.get GRADES_DETAILS_URL + @session_id
        form = page.forms.first
        page = @browser.submit form, form.button('bt_rechercher')

        link = page.iframes[1].content.body.scan(/openPopup\('(.+)','yes','yes'\)/).first.first
        page = @browser.get 'http://e-campus.hei.fr/KonosysProd/' + link

        link = page.body.scan(/window.open\("..\/(.+)"\)/).first.first
        link.gsub! /pdf/, 'doc'
        page = @browser.get 'http://e-campus.hei.fr/KonosysProd/' + link

        # We wait while the PDF is generated by e-campus
        loop do
          sleep 1
          page = @browser.get page.uri

          break if page.body.include?('Erreur du serveur') or page.is_a?(Mechanize::Download)
        end

        # If we had an error on the way
        if page.body.include?('Erreur du serveur')
          throw Exceptions::DownloadError
        end

        # We parse the word document
        doc = Nokogiri::XML page.body_io
        columns = doc.xpath('.//w:tbl[last()]/w:tr[count(w:tc) = 6]/w:tc/w:p/w:r/w:t')
        columns = columns.to_ary.collect! { |elt|
          begin
            elt.children.to_s
          rescue
            ''
          end
        }

        grades = Array.new
        current_cursus = nil

        while (rows = columns.shift(6)).present?
          if rows.first.include?('Cursus')
            current_cursus = rows.first
            next
          end

          course, name, date, type, weight, mark = rows
          unknown = false
          unknown = true if mark.include?('NI') or mark.include?('ABS')

          grades.push GradeDetailedEntity.new(program: current_cursus, course: course, name: name, date: date,
                                              type: type, weight: weight, mark: mark, unknown: unknown)
        end

        grades
      end
    end
  end
end