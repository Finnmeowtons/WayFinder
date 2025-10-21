# Way Finders App – Progress Log

## Current Features

**Map & Stick Functionality**

* OSM map integration with custom markers for sticks
* Static StickModel data displayed on map and in a draggable bottom sheet
* Markers show profile pictures using CircleAvatar
* Tapping a marker moves the map to its location
* Distance calculation between user (placeholder location) and each stick
* Stick list sorted by distance

**Bottom Sheet Stick List**

* Draggable bottom sheet showing all sticks
* Swipe-to-edit functionality on list items
* Tap on a stick in the list moves the map to that stick
* Add stick button (UI only)

**Map Controls**

* Zoom in/out buttons
* My-location button with haptic feedback

**Login / Signup**

* Static landing page with phone number input
* OTP input screen (UI only, no backend yet)
* Logout button with confirmation dialog

## TODO / Future Enhancements

* Replace static login with HTTP API calls
* Implement proper state management (Bloc)
* Fetch stick data dynamically from backend
* Ensure bottom sheet list updates reliably after login
* Show marker tooltips / hover info for better UX
* Improve marker design with shadows / optional animations
* Add profile picture picker & edit functionality fully
* Persistent authentication & session handling
* Push notifications for stick updates
    
