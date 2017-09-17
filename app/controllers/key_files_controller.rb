class KeyFilesController < ApplicationController
   unloadable
 
   before_action :find_project_by_project_id
   before_action :authorize

   def download
     find_key
     unless @key.nil?
       send_file "#{Vault::KEYFILES_DIR}/#{@key.file}", filename: @key.name 
     end
   end

   def find_key
     @key = Vault::KeyFile.find(params[:id])
     unless @key.project_id == @project.id
       redirect_to project_keys_path(@project), alert: t('alert.key.not_found')
       @key = nil
     end
   end

end
