extends Node

var user_data : Dictionary
var login_success = false

func hash_data(data):
	var hashContext = HashingContext.new()
	hashContext.start(HashingContext.HASH_SHA256)
	hashContext.update(data.to_utf8_buffer())
	var hash = hashContext.finish()
	
	return hash.hex_encode()
