# Bitlyzer

Class to shorten URLs with Bit.ly on iOS (both block based and delegate based using ARC).
Try out the included demo project!

If you'd like to include this component as a pod using [CocoaPods](http://cocoapods.org/), just add the following line to your Podfile: `pod "Bitlyzer"`

Simple usage:

- get your [Bitly API credentials](https://bitly.com/a/your_api_key)
- copy Src folder into your project
- import `Bitlyzer.h` in your class
- use Bitlyzer using blocks

``` objective-c
Bitlyzer *bitlyzer = [[Bitlyzer alloc] initWithAPIKey:<BitlyAPIKey> username:<BitlyAPIUsername>];
[bitlyzer shortURL:@"http://albertodebortoli.it"
         succeeded:^(NSString *urlToShorten, NSString *shortenedURL) { }
              fail:^(NSString *urlToShorten, NSError *error) { }];
```

- or use Bitlyzer using delegation pattern making your class conforming to `BitlyzerDelegate` and implementing the optional delegate methods

``` objective-c
Bitlyzer *bitlyzer = [[Bitlyzer alloc] initWithAPIKey:<BitlyAPIKey> username:<BitlyAPIUsername> delegate:self];
[bitlyzer shortURL:@"http://albertodebortoli.it"];
```

``` objective-c
#pragma mark - BitlyzerDelegate
- (void)bitlyzer:(Bitlyzer *)bitlyzer didShortURL:(NSString *)urlToShorten toURL:(NSString *)shortenedURL;
- (void)bitlyzer:(Bitlyzer *)bitlyzer didFailShorteningURL:(NSString *)urlToShorten error:(NSError *)error;
```

Bitly response parsing is done using NSJSONSerializtion available in iOS 5 and later. If you need support for previous iOS versions you need to modify `Bitlyzer.m` and use your preferred JSON parser (line 133).

![1](http://www.albertodebortoli.it/GitHub/Bitlyzer/ss1.png)
![2](http://www.albertodebortoli.it/GitHub/Bitlyzer/ss2.png)

# License

Licensed under the New BSD License.

Copyright (c) 2012, Alberto De Bortoli
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Alberto De Bortoli nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Alberto De Bortoli BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Resources

Info can be found on [my website](http://www.albertodebortoli.it), [and on Twitter](http://twitter.com/albertodebo).
