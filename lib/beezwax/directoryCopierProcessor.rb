require 'fileutils'

class Beezwax
  class DirectoryCopierProcessor < AbstractBeezwaxProcessor
    attr_accessor :directoryForBeezwaxCrashLogs, :directoryToMonitor, :directoryToMonitorListing
    
    def initialize(directoryToMonitor, directoryForBeezwaxCrashLogs)
      @directoryToMonitor = directoryToMonitor
      @directoryToMonitorListing = Dir.entries(@directoryToMonitor)
      @directoryForBeezwaxCrashLogs = directoryForBeezwaxCrashLogs
    end
    
    def processCrash
      destinationDirectory = @directoryForBeezwaxCrashLogs + "/seed-#{@manipulator.seed}.iteration-#{@manipulator.iteration}"
      FileUtils.mkdir_p(destinationDirectory)
      
      FileUtils.cp(@executor.subject.identifyer, "#{destinationDirectory}/")
      
      newDirectoryListing = Dir.entries(@directoryToMonitor)
      newDirectoryListing.each do |d|
        if(!@directoryToMonitorListing.include?(d))
          FileUtils.cp("#{@directoryToMonitor}/#{d}", destinationDirectory)
        end
      end
      
      @directoryToMonitorListing = newDirectoryListing      
      
    end
  end
end