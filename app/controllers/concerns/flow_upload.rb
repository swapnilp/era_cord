module FlowUpload
  extend ActiveSupport::Concern

  def save_file
    FileUtils.mkpath chunk_file_directory
    FileUtils.mv params['file'].tempfile, chunk_file_path, force: true
  end

  def combine_file
    FileUtils.mkpath final_file_directory
    File.open(final_file_path, "a") do |f|
      file_chunks.each do |file_chunk_path|
        f.write File.read(file_chunk_path)
      end
    end
    FileUtils.rm_rf chunk_file_directory
  end

  def final_file_path
    File.join final_file_directory, params['flowFilename']
  end

  def final_file_directory
    Rails.root.join 'tmp', 'flow', "final_#{params['flowIdentifier']}"
  end

  def file_chunks
    Dir["#{chunk_file_directory}/.part*"].sort_by { |f| f.split(".part")[1].to_i }
  end

  def chunk_file_path
    File.join(chunk_file_directory, "#{params['flowFileName']}.part#{params['flowChunkNumber']}")
  end

  def chunk_file_directory
    Rails.root.join 'tmp', 'flow', params['flowIdentifier']
  end

  def last_chunk?
    params['flowChunkNumber'].to_i == params['flowTotalChunks'].to_i
  end

  def upload
    save_file
    combine_file if last_chunk?
    render json: { success: true, message: 'Files uploaded.', file_path: final_file_path, file_directory: final_file_directory.to_s }
  end

end
