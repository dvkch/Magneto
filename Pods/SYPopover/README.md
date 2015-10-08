SYPopover
=========


Popover created with simple navigation controller and view controller subclasses.

####How does it work?

1. Create subclasses of `SYPopoverViewController`, add your subviews to `popoverView` and position them inside:

		- (void)updateFramesAndAlphas
		{
			[super updateFramesAndAlphas];
			// here the self.popoverView.frame is up to date
		}

2. You use `SYPopoverNavigationController` to present subclasses of `SYPopoverViewController`

		-(void)presentAsPopoverFromViewController:(SYPopoverViewController *)viewController animated:(BOOL)animated;



3. You can decide to use a transparent background (iOS 7+) with something like 

		[popoverNavController setBackgroundsColor:[UIColor clearColor]]

4. You know and control when a popover will be closed using the delegate methods

		-(BOOL)popoverNavigationControllerShouldDismiss:(SYPopoverNavigationController *)popoverNavigationController;
		-(void)popoverNavigationControllerWillDismiss:(SYPopoverNavigationController *)popoverNavigationController animated:(BOOL)animated;
		-(void)popoverNavigationControllerWillPresent:(SYPopoverNavigationController *)popoverNavigationController animated:(BOOL)animated;

5. You define the size a view controller will have
		
		BOOL showSmallMenu = ....
		
		[popoverVC setPopoverSizeBlock:^(BOOL iPad, BOOL iPhoneSmallScreen) {
			
			// don't need height > width
			if(showSmallMenu)
				return CGSizeMake(300, 300);
		
			if(iPad) 
				return CGSizeMake(300, 600);
				
			// iPhone and iPods with 3inches screens
			if(iPhoneSmallScreen)
				return CGSizeMake(300, 440);
				
			// Other devices
			return CGSizeMake(300, 500);
		}];
		

License
===

Use it as you like in every project you want, redistribute with mentions of my name and don't blame me if it breaks :)

-- dvkch
 