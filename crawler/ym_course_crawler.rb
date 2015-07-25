require 'crawler_rocks'
require 'json'
require 'pry'

class YangMingUniversityCrawler

	def initialize year: nil, term: nil, update_progress: nil, after_each: nil
		# 只能看最新的課程狀態！！！學年度與學期無法選擇！！！
  @year = year-1911
  @term = term
  @update_progress_proc = update_progress
  @after_each_proc = after_each

  @query_url =  RestClient::Request.execute(url: "https://portal.ym.edu.tw/course/CSCS/CSCS0101List_2?Page=1&PageSize=999&SortColumn=LessonNo&SortDirection=Ascending&Filters.ClassCode=&Filters.Tr_ClassCode=&SearchClass=", method: :get, verify_ssl: false)
 end

 def courses
 	@courses = []

 	doc = Nokogiri::HTML(@query_url)
 	data_c = doc.css('table')[0].css('select')[0].css('option')
 	data_i = doc.css('table')[0].css('select')[1].css('option')

 	for i in 1..data_c.count - 1

	 	department_code = data_c[i].text[0..4]
	 	department = data_c[i].text[5..-1]

	  result_url =  RestClient::Request.execute(url: "https://portal.ym.edu.tw/course/CSCS/CSCS0101List_2?Page=1&PageSize=999&SortColumn=LessonNo&SortDirection=Ascending&Filters.ClassCode=#{department_code}&Filters.Tr_ClassCode=&SearchClass=college", method: :get, verify_ssl: false)
	  doc = Nokogiri::HTML(result_url)

	  for j in 2..doc.css('table')[2].css('tr').count - 1
 		data = []

	  	for k in 0..doc.css('table')[2].css('tr')[j].css('td').count - 1
		  	data[k] = doc.css('table')[2].css('tr')[j].css('td')[k].text
		  end

	  	course = {
	  		year: @year,
	  		term: @term,
	  		department_code: department_code,
	  		department: department,
	  		general_code: data[0],
	  		name: data[1],
	  		required: data[2],
	  		credits: data[3],
	  		hours: data[4],
	  		experiment_hours: data[5],
	  		day_1: data[6],
	  		day_2: data[7],
	  		day_3: data[8],
	  		day_4: data[9],
	  		day_5: data[10],
	  		day_6: data[11],
	  		day_7: data[12],
	  		# department: data[13],
	  		faculty: data[14],
	  		lecturer: data[15],
	  		people_limit: data[16],
	  		people: data[17],
	  		people_now: data[18],
	  		level: data[19],
	  		full_english: data[20],
	  		reading_with_class: data[21],
	  		interscholastic_course: data[22],
	  		notes: data[23],
	  	}

	  	@after_each_proc.call(course: course) if @after_each_proc

	 		# binding.pry
	  	@courses << course
	  end

	 end

	 @courses
 end

end

crawler = YangMingUniversityCrawler.new(year: 2015, term: 1)
File.write('courses.json', JSON.pretty_generate(crawler.courses()))
