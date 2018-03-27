json.set! "@context", ActivityPub::ActivityStream.new(nil).context
json.partial! "activity_pub/version.json.jbuilder", locals: { version: version, account: account }