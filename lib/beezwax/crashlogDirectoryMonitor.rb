require 'fileutils'

class Beezwax
  class CrashlogDirectoryMonitor < AbstractBeezwaxMonitor
    attr_accessor :directoryToMonitor, :directoryToMonitorListing
    
    def initialize(directoryToMonitor)
      @directoryToMonitor = directoryToMonitor
      reInitialize
    end
    
    def isCrash(executor)
      newDirectoryListing = Dir.entries(@directoryToMonitor)
      newDirectoryListing.each do |d|
        if(!@directoryToMonitorListing.include?(d))
          return(true)
        end
      end
      return(false)
    end
    
    def reInitialize
      @directoryToMonitorListing = Dir.entries(@directoryToMonitor)
    end

  end
end