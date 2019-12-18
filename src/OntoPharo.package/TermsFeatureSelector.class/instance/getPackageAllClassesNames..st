string-manipulation
getPackageAllClassesNames: aPackageName
	 |allClassesNames|
	allClassesNames := (RPackageOrganizer default packageNamed: aPackageName)
		  definedClasses collect: [ :each | each instanceSide name ].
	
	^allClassesNames asOrderedCollection  