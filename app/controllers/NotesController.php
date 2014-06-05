<?php

class NotesController extends \BaseController {

	// GET
	public function index() {
		$notes = Note::orderBy('id', 'DESC')->get();
		return Response::json(['notes'=>$notes]);
	}

	// POST
	public function store() {
		$note = new Note();
		$note->body = Input::get('body', 'empty note');
		$note->save();

		return Response::json(['note'=>$note, 'message'=>'Note Created']);
	}

	// GET
	public function show($id) {
		$note = Note::find($id);
		return $note;
	}

	// PUT
	public function update($id) {
		$note = Note::find($id);
		if(Input::has('body')) {
			$note->body = Input::get('body', 'empty note');
			$note->save();
			return Response::json(['note'=>$note, 'message'=>'Note Updated']);
		}
		return Response::json(['note'=>$note, 'message'=>'No Body Sent']);
	}

	// DELETE 
	public function destroy($id) {
		$note = Note::find($id);
		$note->delete();
		return Response::json(['note'=>$note, 'message'=>'Note Deleted']);
	}

}