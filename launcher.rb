require 'mechanize'

#returns whether or not an active CNA certified member exists
def get_cali_cna(firstname, lastname, licensenum)
	found = false #haven't found our value yet
	agent = Mechanize.new

	page = agent.get('http://www.apps.cdph.ca.gov/cvl/SearchPage.aspx')

	form = page.form_with :name =>"aspnetForm"
	
	#select the CNA option
	form.field_with(:id => "ctl00_ContentPlaceHolderMiddleColumn_ddlCertType").option_with(:value => "CNA").select
	form.add_field!('__EVENTTARGET','ctl00$ContentPlaceHolderMiddleColumn$ddlCertType')
    form.add_field!('__EVENTARGUMENT','')
    refreshed_page = agent.submit(form)

    new_form = refreshed_page.form_with :name => "aspnetForm"

    #first try getting by name
	new_form.radiobuttons[1].click
	new_form.field_with(:name => "ctl00$ContentPlaceHolderMiddleColumn$txtLastName").value=lastname
	new_form.field_with(:name => "ctl00$ContentPlaceHolderMiddleColumn$txtFirstName").value=firstname
	
	results_page = new_form.submit(new_form.button_with(:name=>"ctl00$ContentPlaceHolderMiddleColumn$btnSearch2"))

	if results_page.at('div[@id="ctl00_ContentPlaceHolderMiddleColumn_pnlGridViewDetails"]') == nil
		return found
	end

	#now check that the license number exists
	dom = Nokogiri::HTML(results_page.body)
	tdresults = dom.search('//td').map{ |n| n.text }
	for x in 0..tdresults.length
		if tdresults[x] == licensenum && tdresults[x+1].strip == "ACTIVE"
			found = true
			break
		end
	end

	return found 
end

#example call
puts get_cali_cna("Mary", "Smith", "00722865")