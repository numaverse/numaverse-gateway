json.id @batch.id

json.count @batch.batch_items.batched.count

json.items @batch.batch_items.batched do |item|
  json.item_type item.batchable_type
  json.item_id item.batchable_id
end