Class {
	#name : #MyPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'label',
		'button',
		'table'
	],
	#category : 'OntoPharo-UI'
}

{ #category : #specs }
MyPresenter class >> defaultSpec [
	^ SpPanedLayout newVertical
		  add: #table;
		  add: (SpBoxLayout newHorizontal
				   add: #label;
				   add: #button;
				   yourself)
		  "withConstraints: [ :cstr | cstr height: 30 ]";
		  yourself
]

{ #category : #specs }
MyPresenter class >> open [
	<script>
	self new openWithSpec
]

{ #category : #specs }
MyPresenter class >> title [
	^ 'Ontologue'
]

{ #category : #initialization }
MyPresenter >> initializeWidgets [
	label := SpLabelPresenter new.
	button := SpButtonPresenter new action: [ table items: { 5 } ]; label: 'Set'.
	table := SpTablePresenter new
		         items: { 1. 2. 4 };
		         addColumn:
			         (SpStringTableColumn new evaluated: [ :int | int asString ]);
		         whenSelectionChangedDo: [ :selection | selection inspect ];
		         yourself
]
