# Bitlyzer

Class to shorten URLs with Bit.ly on iOS (both block based and delegate based using ARC).
Try out the included demo project!

Simple usage:

- copy Src folder into your project
- set your Bitly API username and key in Bitlyzer.m 
- import `Bitlyzer.h` in your class
- use Bitlyzer using blocks

``` objective-c
Bitlyzer *bitlyzer = [[Bitlyzer alloc] init];
[bitlyzer shortURL:@"http://albertodebortoli.it"
         succeeded:^(NSString *urlToBitly, NSString *shortenURL) { }
              fail:^(NSString *urlToBitly, NSError *error) { }];
```

- or use Bitlyzer using delegation pattern implementing `BitlyzerDelegate` protocol and related optional delegate methods

``` objective-c
Bitlyzer *bitlyzer = [[Bitlyzer alloc] initWithDelegate:self];
[bitlyzer shortURL:@"http://albertodebortoli.it"];
```

``` objective-c
#pragma mark - BitlyzerDelegate
- (void)bitlyReturnedOkForURL:(NSString *)urlString shortenURL:(NSString *)shortenURL { ... }
- (void)bitlyReturnedErrorForURL:(NSString *)urlString { ... }
```

Bitly response parsing is done using NSJSONSerializtion available in iOS 5 and later. If you need support for previous iOS versions you need to modify `Bitlyzer.m` and use your preferred JSON parser (line 105). 

![1](http://www.albertodebortoli.it/GitHub/Bitlyzer/screenshot1.png) 
![2](http://www.albertodebortoli.it/GitHub/Bitlyzer/screenshot2.png)

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
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Resources

Info can be found on [my website](http://www.albertodebortoli.it), [and on Twitter](http://twitter.com/albertodebo).
