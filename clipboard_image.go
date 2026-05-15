package main

/*
#cgo darwin CFLAGS: -x objective-c
#cgo darwin LDFLAGS: -framework AppKit -framework Foundation
#include <stdlib.h>
#import <AppKit/AppKit.h>

char* saveClipboardImage(const char* pathC, const char* typeC) {
	@autoreleasepool {
		NSString *path = [NSString stringWithUTF8String:pathC];
		NSString *type = [NSString stringWithUTF8String:typeC];
		NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
		NSImage *image = [[NSImage alloc] initWithPasteboard:pasteboard];

		if (image == nil) {
			return strdup("no image found in clipboard");
		}

		NSData *tiffData = [image TIFFRepresentation];
		if (tiffData == nil) {
			return strdup("could not read clipboard image data");
		}

		NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
		if (bitmap == nil) {
			return strdup("could not convert clipboard image data");
		}

		NSBitmapImageFileType fileType = NSBitmapImageFileTypePNG;
		NSDictionary *properties = @{};
		if ([type isEqualToString:@"jpeg"]) {
			fileType = NSBitmapImageFileTypeJPEG;
			properties = @{NSImageCompressionFactor: @0.95};
		} else if ([type isEqualToString:@"tiff"]) {
			fileType = NSBitmapImageFileTypeTIFF;
		}

		NSData *outputData = [bitmap representationUsingType:fileType properties:properties];
		if (outputData == nil) {
			return strdup("could not encode image");
		}

		if (![outputData writeToFile:path atomically:YES]) {
			return strdup("failed to write output file");
		}

		return NULL;
	}
}
*/
import "C"

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"unsafe"
)

func main() {
	flag.Usage = func() {
		fmt.Fprintf(flag.CommandLine.Output(), "Usage: %s OUTPUT_FILE\n", filepath.Base(os.Args[0]))
		fmt.Fprintln(flag.CommandLine.Output(), "\nSaves the current macOS clipboard image to OUTPUT_FILE.")
		fmt.Fprintln(flag.CommandLine.Output(), "Supported extensions: .png, .jpg, .jpeg, .tif, .tiff")
		fmt.Fprintf(flag.CommandLine.Output(), "\nExample:\n  %s screenshot.png\n", filepath.Base(os.Args[0]))
	}
	flag.Parse()

	if flag.NArg() != 1 {
		flag.Usage()
		os.Exit(2)
	}

	outputPath := flag.Arg(0)
	ext := strings.ToLower(strings.TrimPrefix(filepath.Ext(outputPath), "."))
	if ext == "" {
		outputPath += ".png"
		ext = "png"
	}

	switch ext {
	case "png":
	case "jpg", "jpeg":
		ext = "jpeg"
	case "tif", "tiff":
		ext = "tiff"
	default:
		fmt.Fprintf(os.Stderr, "unsupported output extension %q; use .png, .jpg, .jpeg, .tif, or .tiff\n", filepath.Ext(outputPath))
		os.Exit(2)
	}

	absOutputPath, err := filepath.Abs(outputPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "resolve output path: %v\n", err)
		os.Exit(1)
	}

	cPath := C.CString(absOutputPath)
	cType := C.CString(ext)
	defer C.free(unsafe.Pointer(cPath))
	defer C.free(unsafe.Pointer(cType))

	if errMsg := C.saveClipboardImage(cPath, cType); errMsg != nil {
		defer C.free(unsafe.Pointer(errMsg))
		fmt.Fprintln(os.Stderr, C.GoString(errMsg))
		os.Exit(1)
	}

	fmt.Printf("saved %s\n", absOutputPath)
}
