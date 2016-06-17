# -*- coding: utf-8 -*-
module Ruboty
  module Pdq
    module Actions
      class List < Ruboty::Actions::Base
        # set env var
        SDB_URL       = ENV['RUBOTY_SDB_URL']
        SDB_LINK_URL  = ENV['RUBOTY_SDB_LINK_URL']
        URL_PREFIX  = "#{SDB_LINK_URL}/hibiki/BRDDocument.do?func=view&binderId=14979&recordId="
        
        def call
          # SDBアクセス、その他ユーティリティのインスタンス化
          sdb   = Ruboty::Pdq::Helpers::SmartDB.new(message)
          util  = Ruboty::Pdq::Helpers::Util.new(message)
          slack = Ruboty::Pdq::Helpers::Slack.new(message)

          period = message[:period].to_i if !message[:period].nil?
          period = 3 if period.nil?
          
          # get total record count
          count_path  = "/hibiki/rest/1/binders/14979/views/10032/documents"
          url         = "#{SDB_URL}#{count_path}"
          resp_hash   = sdb.send_request(url)
          total_count = resp_hash[:totalCount].to_i if !resp_hash[:totalCount].nil?

          # get list of pdq
          page_size    = 10000
          max_page_num = (total_count/page_size.to_f).ceil
          qsn_list     = {}
          (1..max_page_num).each do |num|
            url        = "#{SDB_URL}#{count_path}?pageSize=#{page_size}&pageNumber=#{num}"
            resp_hash  = sdb.send_request(url)
            resp_hash[:document].each do |qsn|
              qsn_info = {}
              qsn_info[:title] = qsn[:name]
              elapsed_time = Time.now - Time.strptime(qsn[:updated_at],"%Y-%m-%dT%H:%M:%S%:z")
              qsn_info[:elapsed_time] = elapsed_time
              qsn[:item].each do |item|
                if item[:id] == "10054" # Status
                  next if item[:value].nil? or item[:value][:name].nil?
                  qsn_info[:status] = item[:value][:name]
                elsif item[:id] == "10050" # Assigned Member
                  next if item[:value].nil?
                  member_ary = item[:value]
                  member_ary = [item[:value]] if !item[:value].is_a?(Array)
                  members = []
                  member_ary.each do |member|
                    members.push(member[:name])
                  end
                  qsn_info[:members] = members
                elsif item[:id] == "10079" # Question Number
                  next if item[:value].nil?
                  qsn_info[:qsn_num] = item[:value]
                end
              end # qsn[:item].each do |item|
              qsn_list[qsn[:id]] = qsn_info
            end # resp_hash[:document].each do |qsn|
          end # (1..max_page_num).each do |num|
          puts message
          # make message
          char_count = 50
          lines = 15
          line_limit = 30
          msg_str = "#{Time.now.strftime('%Y/%m/%d %H:%M')}時点で#{period}日以上動いていない問合せの一覧だよ\n```"
          msg_str << " 経過 |   ステータス   |  担当者  | 問合せタイトル\n"
          msg_str << "------+----------------+----------+---------------------\n"
          qsn_list.sort {|(k1, v1), (k2, v2)| v2[:elapsed_time] <=> v1[:elapsed_time] }.each do |id, info|
            days = (info[:elapsed_time]/86400).floor
            next if days < period
            hours = ((info[:elapsed_time]-days*86400)/3600).floor
            #表示するタイトルを生成(表示幅を一定までで抑える)
            title = String.new
            i = 0
            count = 0
            while true do
              break if info[:title][i].nil?
              if info[:title][i].ascii_only? # 半角
                count = count + 1
              else # 全角
                count = count + 2
              end
              if count > char_count
                title << "…"
                break
              end
              title << info[:title][i]
              i = i + 1
            end
            if lines >= line_limit
              msg_str << "```"
              slack.send_message(msg_str)
              msg_str = "続きだよ\n```"
              msg_str << " 経過 |   ステータス   |  担当者  | 問合せタイトル\n"
              msg_str << "------+----------------+----------+---------------------\n"
              lines = 0
            end
            msg_str << sprintf(" %2d日 |%s|%s|%s\n",
                        days,
                        util.pad_to_print_size(info[:status], 16),
                        util.pad_to_print_size(info[:members][0],8),
                        "<#{URL_PREFIX}#{id}|#{title}>"
                        )
            #msg_str << sprintf(" %2d日 |%s|%s|%s\n",
            #            days,
            #            util.pad_to_print_size(info[:status], 16),
            #            util.pad_to_print_size(info[:members][0],10),
            #            title)
            lines = lines + 1
            if info[:members].size >= 2
              (1..info[:members].size-1).each do |i|
                if lines >= line_limit
                  msg_str << "```"
                  slack.send_message(msg_str)
                  msg_str = "続きだよ\n```"
                  msg_str << " 経過 |   ステータス   |  担当者  | 問合せタイトル\n"
                  msg_str << "------+----------------+----------+---------------------\n"
                  lines = 0
                end
                msg_str << sprintf("      |                |%s|\n",util.pad_to_print_size(info[:members][i],10))
                lines = lines + 1
              end
            end
          end
          msg_str << "```"
          slack.send_message(msg_str)
          #slack.send_message(msg_str)
        rescue => e
          message.reply(e.message)
        end #def call
        
        private

        
      end 
    end
  end
end
