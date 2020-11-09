extends Node


func current_earning():
	return ResourceManager.current_earning
	
func last_earning():
	return ResourceManager.last_earning
	
func compare_earning():
	return ResourceManager.current_earning > ResourceManager.last_earning 
	
func compare_earning_str():
	return "More than" if ResourceManager.current_earning > ResourceManager.last_earning else "Not more than"

func current_reputation():
	return ResourceManager.current_reputation
	
func last_reputation():
	return ResourceManager.last_reputation
	
func compare_reputation():
	return ResourceManager.current_reputation > ResourceManager.last_reputation 
	
func compare_reputation_str():
	return "More than" if ResourceManager.current_reputation > ResourceManager.last_reputation else "Not more than"
