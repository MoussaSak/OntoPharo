test
testSplitAllPackageClassesNames
	| ordCollection |
	ordCollection :=  #(#(#Baseline #Of #Zodiac)).

	self
		assert: ordCollection
		equals: (tfs splitAllPackageClassesNames: 'BaselineOfZodiac') 