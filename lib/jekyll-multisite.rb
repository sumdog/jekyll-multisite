"""
    jekyll-multisite Sumit Khanna - http://penguindreams.org 

    ---

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

require 'jekyll'
require 'jekyll/reader'
require 'jekyll/cleaner'
require 'fileutils'
require 'pathname'

module Jekyll

  # Originally part of jekyll-unsanatize gem

  class << self
    def sanitized_path(base_directory, questionable_path)
     
     if base_directory.eql?(questionable_path)
       base_directory
     elsif questionable_path.start_with?(base_directory)
       questionable_path
     elsif File.exists?(questionable_path) and !questionable_path.start_with?('/') and (ENV['OS'] == 'Windows_NT')
       File.expand_path(questionable_path)
     elsif File.exists?(questionable_path) and questionable_path != '/' and !(ENV['OS'] == 'Windows_NT')
       File.expand_path(questionable_path)
     else
       File.join(base_directory, questionable_path)
     end
    
    end
  end

  class Cleaner
    def parent_dirs(file)
      parent_dir = File.dirname(file)
      if parent_dir == '/' or File.dirname(parent_dir) == parent_dir or !parent_dir.start_with?(site.dest)
        []
      elsif parent_dir == site.dest
        []
      else
        [parent_dir] + parent_dirs(parent_dir)
      end
    end
  end
  
  # Shared source reader

  class Reader

    def read
      @site.layouts = LayoutReader.new(site).read
      read_directories
 
      if @site.config['shared_dir']
        read_directories File.join('..', @site.config['shared_dir'])
      end
      
      sort_files!
      @site.data = DataReader.new(site).read(site.config['data_dir'])
      CollectionReader.new(site).read
    end
    
  end


  # Move the _shared directories to the correct location
  #   (very hacky - we move all the files to the correct 
  #    location with a hook after the site is written/rendered)

  def self.sync_dir(cur, base,  dest)
    Dir.glob( File.join(cur, '*'), File::FNM_DOTMATCH).each do |f|
      
      rel = Pathname.new(f).relative_path_from(base)
      dest_dir = File.join(dest, rel)
      
      if File.basename(f) == '.' or File.basename(f) == '..'
        next 
      elsif File.directory?(f)
	      if not File.exists?(dest_dir)
	        Dir.mkdir(dest_dir)
	      end
        sync_dir(f, base, dest)
	      Dir.rmdir(f)
      else
	      FileUtils.mv(f, dest_dir)
      end
    end
  end

  Jekyll::Hooks.register :site, :post_write do |site|
    base_shared = File.basename(site.config['shared_dir'])
    shared_dir = File.join(site.dest, base_shared)
    static_shared_dir = File.join(Configuration::DEFAULTS['destination'], base_shared)
    
    sync_dir(shared_dir, Pathname.new(shared_dir), site.dest)
    sync_dir(static_shared_dir, Pathname.new(static_shared_dir), site.dest)
    
    Dir.rmdir(shared_dir)
    Dir.rmdir(static_shared_dir)
  end

  # excluded files

  class EntryFilter

    def relative_to_source(entry)

      shared_base = File.join('/..', @site.config['shared_dir'])
      rel_path = File.join(base_directory, entry)

      if base_directory.start_with?(shared_base)
        rel_path.sub(/^#{shared_base}/,'')
      else
        rel_path
      end
    end

  end

  # jekyll-pagination fixes for multi-side

  begin
    require "jekyll-paginate"
    
    module Paginate

      class Pager
        def self.pagination_candidate?(config, page)
          page.name == 'index.html'
        end
      end
      
      class Pagination < Generator
        def paginate(site, page)
          all_posts = site.site_payload['site']['posts']
          all_posts = all_posts.reject { |p| p['hidden'] }
          pages = Pager.calculate_pages(all_posts, site.config['paginate'].to_i)
          (1..pages).each do |num_page|
            pager = Pager.new(site, num_page, all_posts, pages)
            if num_page > 1

              # Here is our monkey patch
	            if File.basename(page.dir) == site.config['shared_dir']
	              base = File.expand_path(File.join(site.source, '..'))
                newpage = Page.new(site, base, page.dir, page.name)
              else
	              newpage = Page.new(site, site.source, page.dir, page.name)
	            end

	            newpage.pager = pager
              newpage.dir = Pager.paginate_path(site, num_page)
              site.pages << newpage
            else
              page.pager = pager
            end
          end
        end
      end

    end
  rescue LoadError
    # not installed
  end

end
