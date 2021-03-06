#!/Users/awojnarek/.rbenv/versions/3.0.0-preview1/bin/ruby
require 'time'
require 'pp'

#############
# Variables #
#############
file = ARGV[0]
debug = false

#############
# Functions #
#############

# Days left in secon
daysToCheck = 90
secondsLeft = 86400 * daysToCheck

########
# Main #
########
if file == nil then
    printf "You must specify a file!\n"
    exit
end

array = %x[cat #{file}].split("\n")

array.each_with_index do |e,i|
    if e =~ /To / then
        date = e.split(" : ").last.strip
        t = Time.parse(date).to_i
        now = Time.now.to_i
        delta = t - now

        if delta < secondsLeft then
            label = nil
            count = 0
            while label == nil do
                if array[i-count] !~ /Label/
                    count = count + 1
                else
                    label = array[i-count].split(" : ").last.strip
                end
            end

            if label == nil then
                label = "LINE " + (i+1).to_s + " OF FILE"
            end 
            
            if debug == true then print "\nDEBUG #{e}\n" end
            printf "Cert (#{label}) Expiring in: #{delta / 86400} days.\n"
        end
    end

    if e =~ /until:/ then
        date = e.split("until:")[1].split("Certificate")[0].strip
        if date !~ /\// then
            t = Time.parse(date).to_i
            now = Time.now.to_i
            delta = t - now
            label = nil
            count = 0
            
            if e =~ /CN=/ then
                label = e.split("until:")[0].split("CN=")[1].split(",")[0]
            end

            if e =~ /OU=/ then
                label = e.split("until:")[0].split("OU=")[1].split(",")[0]
            end

            while label == nil do
                if count > 10000 then
                    label = "UNKNOWN"
                end
                if array[i-count] !~ /CN=/
                    count = count + 1
                else
                    label = array[i-count].split("CN=")[1].split(",")[0]
                end
            end

            if label == nil then
                label = "LINE " + (i+1).to_s + " OF FILE"
            end 

            if delta < secondsLeft then
                if debug == true then print "\nDEBUG #{e}\n" end
                printf "Cert (#{label}) Expiring in: #{delta / 86400} days.\n"
            end
        else
            t = DateTime.strptime(date, '%m/%d/%y %H:%M %p').to_time.to_i
            now = Time.now.to_i
            delta = t - now

            label = nil
            if e =~ /CN=/ then
                label = e.split("until:")[0].split("CN=")[1].split(",")[0]
            end

            if e =~ /OU=/ then
                label = e.split("until:")[0].split("OU=")[1].split(",")[0]
            end

            count = 0
            while label == nil do
                if count > 10000 then
                    label = "UNKNOWN"
                end
                if array[i-count] !~ /CN=/
                    count = count + 1
                else
                    label = array[i-count].split("CN=")[1].split(",")[0]
                end
            end

            if label == nil then
                label = "LINE " + (i+1).to_s + " OF FILE"
            end 

            if delta < secondsLeft then
                if debug == true then print "\nDEBUG #{e}\n" end
                printf "Cert (#{label}) Expiring in: #{delta / 86400} days.\n"
            end
        end
        
    end
end