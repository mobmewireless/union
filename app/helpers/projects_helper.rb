module ProjectsHelper
  def git_display_url(git_url)
    return_value = git_url

    match_data = if git_url.starts_with? 'https://'
      /^https:\/\/(?<host>[a-z0-9\.-]+)\/(?<project>[\w\.-]+)\/(?<repository>[\w\.-]+).git$/i.match(git_url)
    elsif git_url.starts_with? 'git@'
      /^git@(?<host>[a-z0-9\.-]+):(?<project>[\w\.-]+)\/(?<repository>[\w\.-]+).git$/i.match(git_url)
    end

    if match_data
      return_value = "<a href='https://#{match_data[:host]}/#{match_data[:project]}/#{match_data[:repository]}' title='#{git_url}'>#{match_data[:repository]}</a>".html_safe
    end

    return_value
  end

  def since_last_job(job)
    if job
      "<abbr title=#{job.created_at.iso8601}>#{time_ago_in_words(job.created_at, include_seconds: false)} ago</abbr>"
    else
      '<em>Never</em>'
    end.html_safe
  end
end