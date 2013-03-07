window.init_resource_list = () ->
  init_delete_resource_button()

window.init_resource_view = () ->
  init_delete_resource_button()

window.init_resource_upload = () ->
  if window.File and window.FileList and window.FileReader
    window.file_uploader = new FileUploader
      upload_handler: upload_handler
      selector: $('.file')
      drop_area: $('.drop-area')
      confirm_message: 'Files are still being uploaded.'
      upload_url: $('.file').data('get-upload-url')
      allowed_types: []
      max_size: 1024 * 1024 * 1024

upload_handler =
  preview: (file) ->
    $resource = $ """
        <li class="span3">
          <div class="thumbnail">
            <div class="preview"></div>
            <h5>#{file.name}</h5>
            <div class="progress">
              <div class="bar" style="width: 0%;"></div>
            </div>
          </div>
        </li>
      """
    $preview = $('.preview', $resource)

    if file_uploader.active_files < 16 and file.type.indexOf("image") is 0
      reader = new FileReader()
      reader.onload = (e) =>
        $preview.css('background-image', "url(#{e.target.result})")
      reader.readAsDataURL(file)
    else
      $preview.text(file.type or 'application/octet-stream')

    $('.resource-uploads').prepend($resource)

    (progress, resource, error) =>
      if error == undefined
        $('.bar', $resource).css
          width: "#{progress}%"
        $('.bar', $resource).text("#{progress}% of #{size_human(file.size)}")
        if resource
          $('.bar', $resource).addClass('bar-success')
          $('.bar', $resource).text("Success #{size_human(file.size)}")
          if resource.image_url and $preview.text().length > 0
            $preview.css('background-image', "url(#{resource.image_url})")
            $preview.text('')
      else
        $('.bar', $resource).css('width', '100%')
        $('.bar', $resource).addClass('bar-danger')
        if error == 'too_big'
          $('.bar', $resource).text("Failed! Too big, max: #{size_human(file_uploader.max_size)}.")
        else if error == 'wrong_type'
          $('.bar', $resource).text("Failed! Wrong file type.")
        else
          $('.bar', $resource).text('Failed!')


window.init_delete_resource_button = () ->
  $('body').on 'click', '.btn-delete', (e) ->
    e.preventDefault()
    if confirm('Press OK to delete the resource')
      $(this).attr('disabled', 'disabled')
      service_call 'POST', $(this).data('service-url'), (err, result) =>
        if err
          $(this).removeAttr('disabled')
          LOG 'Something went terribly wrong during delete!', err
          return
        target = $(this).data('target')
        redirect_url = $(this).data('redirect-url')
        if target
          $("#{target}").remove()
        if redirect_url
          window.location.href = redirect_url

