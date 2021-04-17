//
//  ToottiDefinitions.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-28.
//

#ifndef ToottiDefinitions_h
#define ToottiDefinitions_h

// Background light teal (#8DA7B3)
#define BACKGROUND_LIGHT_TEAL [UIColor colorWithRed:141/255.0f green:167/255.0f blue:179/255.0f alpha:1.0f]
// Button dark teal (#306376)
#define BUTTON_DARK_TEAL [UIColor colorWithRed:48/255.0f green:99/255.0f blue:118/255.0f alpha:1.0f]
// Logo and icon yellow (#F8C257)
#define LOGO_GOLDEN_YELLOW [UIColor colorWithRed:248/255.0f green:194/255.0f blue:87/255.0f alpha:1.0f]


// BUTTON INFO
#define NORMAL_BUTTON_CORNER_RADIUS 5
#define NORMAL_BUTTON_FONT_TYPE @"HelveticaNeue"
#define NORMAL_BUTTON_FONT_SIZE 17

// TABLE INFO
#define NORMAL_TABLE_CORNER_RADIUS 10

// VIEW INFO
#define SCREEN_WIDTH self.view.bounds.size.width
#define SCREEN_HEIGHT self.view.bounds.size.height

//custom let & var
#ifndef let
#define let __auto_type const
#endif

#ifndef var
#define var __auto_type
#endif

// PLAYBACK SETTINGS
#define MERGE_PLAYBACK_TIME_BUFFER 0.01 // 10ms time delay from current device_time

//recording waveform offset for iPhone 8plus
#define WAVEFORM_RECORDING_OFFSET_IPHONE8  40



#endif /* ToottiDefinitions_h */
