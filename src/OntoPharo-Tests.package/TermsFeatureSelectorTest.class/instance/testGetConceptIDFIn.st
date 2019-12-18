test
testGetConceptIDFIn
	| idf |
	idf := tfs getConceptTFIDF: 'Test' in: 'This is a document in Test'.
	self assert: idf closeTo: 0.