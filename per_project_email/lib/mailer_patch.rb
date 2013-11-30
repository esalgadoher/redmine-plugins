# To change this template, choose Tools | Templates
# and open the template in the editor.

require_dependency 'mailer'

module MailerPatch
  
  def self.included(base)
    base.extend (ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
     alias_method_chain :issue_add, :flexible_sender
     alias_method_chain :issue_edit, :flexible_sender
     alias_method_chain :document_added, :flexible_sender
     alias_method_chain :attachments_added, :flexible_sender
     alias_method_chain :news_added, :flexible_sender
     alias_method_chain :news_comment_added, :flexible_sender
     alias_method_chain :message_posted, :flexible_sender
     alias_method_chain :wiki_content_added, :flexible_sender
     alias_method_chain :wiki_content_updated, :flexible_sender
    end
   end
  
  module ClassMethods
  
  end
  module InstanceMethods
    
    def issue_add_with_flexible_sender(issue)
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login
    redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
    message_id issue
    @project=Project.find(issue.project.identifier)
    @author = issue.author
    @issue = issue
    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)
    recipients = issue.recipients
    cc = issue.watcher_recipients - recipients
    email = @project.email.blank? ? Setting.mail_from : @project.email
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}",
      :from => email
    end
    
  def issue_edit_with_flexible_sender(journal)
    issue = journal.journalized.reload
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login
    redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
    message_id journal
    references issue
    @author = journal.user
    recipients = issue.recipients
    # Watchers in cc
    cc = issue.watcher_recipients - recipients
    s = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
    s << "(#{issue.status.name}) " if journal.new_value_for('status_id')
    s << issue.subject
    @project=Project.find(issue.project.identifier)
    @issue = issue
    @journal = journal
    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue, :anchor => "change-#{journal.id}")
    email = @project.email.blank? ? Setting.mail_from : @project.email
    mail :to => recipients,
      :cc => cc,
      :subject => s,
      :from => email
  end

  def document_added_with_flexible_sender(document)
    redmine_headers 'Project' => document.project.identifier
    @author = User.current
    @document = document
    @document_url = url_for(:controller => 'documents', :action => 'show', :id => document)
    @project=Project.find(document.project.identifier)
    email = @project.email.blank? ? Setting.mail_from : @project.email
    mail :to => document.recipients,
      :subject => "[#{document.project.name}] #{l(:label_document_new)}: #{document.title}",
      :from => email
   end
   
    def attachments_added_with_flexible_sender(attachments)
    container = attachments.first.container
    added_to = ''
    added_to_url = ''
    @author = attachments.first.author
    case container.class.name
    when 'Project'
      added_to_url = url_for(:controller => 'files', :action => 'index', :project_id => container)
      added_to = "#{l(:label_project)}: #{container}"
      recipients = container.project.notified_users.select {|user| user.allowed_to?(:view_files, container.project)}.collect  {|u| u.mail}
    when 'Version'
      added_to_url = url_for(:controller => 'files', :action => 'index', :project_id => container.project)
      added_to = "#{l(:label_version)}: #{container.name}"
      recipients = container.project.notified_users.select {|user| user.allowed_to?(:view_files, container.project)}.collect  {|u| u.mail}
    when 'Document'
      added_to_url = url_for(:controller => 'documents', :action => 'show', :id => container.id)
      added_to = "#{l(:label_document)}: #{container.title}"
      recipients = container.recipients
    end
    redmine_headers 'Project' => container.project.identifier
    @attachments = attachments
    @added_to = added_to
    @added_to_url = added_to_url
    @project=Project.find(container.project.identifier)
    email = @project.email.blank? ? Setting.mail_from : @project.email
    mail :to => recipients,
      :subject => "[#{container.project.name}] #{l(:label_attachment_new)}",
      :from => email
  end
  
  def news_added_with_flexible_sender(news)
    redmine_headers 'Project' => news.project.identifier
    @author = news.author
    message_id news
    @news = news
    @news_url = url_for(:controller => 'news', :action => 'show', :id => news)
    @project=Project.find(news.project.identifier)
    email = @project.email.blank? ? Setting.mail_from : @project.email
    mail :to => news.recipients,
      :subject => "[#{news.project.name}] #{l(:label_news)}: #{news.title}",
      :from => email
  end
  
   def news_comment_added_with_flexible_sender(comment)
    news = comment.commented
    redmine_headers 'Project' => news.project.identifier
    @author = comment.author
    message_id comment
    @news = news
    @comment = comment
    @news_url = url_for(:controller => 'news', :action => 'show', :id => news)
    @project=Project.find(news.project.identifier)
    email = @project.email.blank? ? Setting.mail_from : @project.email
    mail :to => news.recipients,
     :cc => news.watcher_recipients,
     :subject => "Re: [#{news.project.name}] #{l(:label_news)}: #{news.title}",
     :from => email
  end
  
   def message_posted_with_flexible_sender(message)
    redmine_headers 'Project' => message.project.identifier,
                    'Topic-Id' => (message.parent_id || message.id)
    @author = message.author
    message_id message
    references message.parent unless message.parent.nil?
    recipients = message.recipients
    cc = ((message.root.watcher_recipients + message.board.watcher_recipients).uniq - recipients)
    @message = message
    @message_url = url_for(message.event_url)
    @project=Project.find(message.project.identifier)
    email = @project.email.blank? ? Setting.mail_from : @project.email
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{message.board.project.name} - #{message.board.name} - msg#{message.root.id}] #{message.subject}",
      :from => email
  end
  
   def wiki_content_added_with_flexible_sender(wiki_content)
    redmine_headers 'Project' => wiki_content.project.identifier,
                    'Wiki-Page-Id' => wiki_content.page.id
    @author = wiki_content.author
    message_id wiki_content
    recipients = wiki_content.recipients
    cc = wiki_content.page.wiki.watcher_recipients - recipients
    @wiki_content = wiki_content
    @wiki_content_url = url_for(:controller => 'wiki', :action => 'show',
                                      :project_id => wiki_content.project,
                                      :id => wiki_content.page.title)
    @project=Project.find(wiki_content.project.identifier)
    email = @project.email.blank? ? Setting.mail_from : @project.email
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{wiki_content.project.name}] #{l(:mail_subject_wiki_content_added, :id => wiki_content.page.pretty_title)}",
      :from => email
  end
  
   def wiki_content_updated_with_flexible_sender(wiki_content)
    redmine_headers 'Project' => wiki_content.project.identifier,
                    'Wiki-Page-Id' => wiki_content.page.id
    @author = wiki_content.author
    message_id wiki_content
    recipients = wiki_content.recipients
    cc = wiki_content.page.wiki.watcher_recipients + wiki_content.page.watcher_recipients - recipients
    @wiki_content = wiki_content
    @wiki_content_url = url_for(:controller => 'wiki', :action => 'show',
                                      :project_id => wiki_content.project,
                                      :id => wiki_content.page.title)
    @wiki_diff_url = url_for(:controller => 'wiki', :action => 'diff',
                                   :project_id => wiki_content.project, :id => wiki_content.page.title,
                                   :version => wiki_content.version)
    @project=Project.find(wiki_content.project.identifier)
    email = @project.email.blank? ? Setting.mail_from : @project.email
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{wiki_content.project.name}] #{l(:mail_subject_wiki_content_updated, :id => wiki_content.page.pretty_title)}",
      :from => email
  end
  end
end

Mailer.send(:include, MailerPatch)
