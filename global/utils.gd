extends Node
class_name Utils

@export var rows :int
@export var cols :int

func trim(row_count:int, grids :Array) -> Dictionary:
	var new_grid :Dictionary = {}
	
	cols = row_count
	rows = row_count
	
	for row in range(row_count):
		var col = 0
		for c in grids[row]:
			new_grid[Vector2(col, row)] = c
			col += 1
			
	for row in range(row_count):
		if not _is_col_all_empty(row, new_grid):
			continue
			
		for col in range(cols):
			new_grid.erase(Vector2(row, col))
			
		rows -= 1
		
	for col in range(row_count):
		if not _is_row_all_empty(col, new_grid):
			continue
			
		for row in range(rows):
			new_grid.erase(Vector2(row, col))
			
		cols -= 1
			
	return new_grid
	
func _is_row_all_empty(col :int, grid :Dictionary) -> bool:
	for row in range(rows):
		if not grid[Vector2(row, col)].is_empty():
			return false
			
	return true

func _is_col_all_empty(row :int, grid :Dictionary) -> bool:
	for col in range(cols):
		if not grid[Vector2(row, col)].is_empty():
			return false
			
	return true
