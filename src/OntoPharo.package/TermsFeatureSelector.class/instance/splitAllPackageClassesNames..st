string-manipulation
splitAllPackageClassesNames: aPackageName
	| aPackageAllClassesNames allClassesNamesAsCollection |
	aPackageAllClassesNames := self getPackageAllClassesNames:
		                           aPackageName.
	allClassesNamesAsCollection := aPackageAllClassesNames collect: [ 
		                               :className | 
		                               self splitClassName: className ].
	^ (allClassesNamesAsCollection collect: [ :e | 
		   (e collect: #asSymbol) asArray ]) asArray