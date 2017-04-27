# SYPopoverController

`UIPresentationController` subclass to show a `UIViewController` centered on-screen, with the desired `preferredContentSize`. 

PS: sorry, not the best name, but `SYPopupController` was already taken.

#### Sample code

```
// 1. The controllers your want to present in the popover
UINavigationController *navController = [[UINavigationController alloc] init];
UIViewController *viewController = [[UIViewController alloc] init];
[navController setViewControllers:@[viewController]];

// 2. Prepare the navigationController to use SYPopoverController
[navController setModalPresentationStyle:UIModalPresentationCustom];
[navController setTransitioningDelegate:[SYPopoverTransitioningDelegate shared]];

// 3. Present
[self presentViewController:navController animated:YES completion:nil];

// (Optional) 4. Access the popoverController to use the background you wish
// Here we use a semi-transparent white color
SYPopoverController *popoverController = (SYPopoverController *)navController.presentationController;
[popoverController.backgroundView setBackgroundColor:[UIColor colorWithWhite:1. alpha:0.6]];

// Alternative to 2+3: use the helper method
[self sy_presentPopover:navController animated:YES completion:nil];

```

#### Customizations

###### Background

By default there is no background. You have two options to change this behaviour:

- Implement `popoverControllerBackgroundColor:` from `SYPopoverContentViewDelegate` in presented view controllers


- Access the background view using the following code, and change its background color or add a subview
		 
		 [(SYPopoverController *)myViewController.presentationController backgroundView]
		 
###### Dismiss

By default when the user taps the background of the `popoverController` it is dismissed. You can override this behaviour by conforming to `SYPopoverContentViewDelegate` and implementing `popoverControllerShouldDismissOnBackgroundTap:`

License
===

Use it as you like in every project you want, redistribute with mentions of my name and don't blame me if it breaks :)

-- dvkch
 
