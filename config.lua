--calculate the aspect ratio of the device:
local aspectRatio = display.pixelHeight / display.pixelWidth

application = {
   content = {
      width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
      height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),
      scale = "letterbox",
      fps = 60,

      imageSuffix = {
         ["@2x"] = 2.0,
         ["@4x"] = 4.0,
      },
   },
   license = {
      google = {
         key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoXLZWD4jIWKYoHP0NG53nlQgy433hFyZyAtCM5+ruy384EiXnp39iTTSSczBa9H6VGnaTfZHTdN/hHJVwJrzLask1kzd9/2UPeZEiJQK1wWUseWqOG8uPqlAmyc+fBVPUpupTNJoJWSOsCfijCoZv2bhwI2scIGJzvmdToyJYROxk/RUr7BWKqj7sKFJ+CeutdkXnxkA/1Efo4YArW/JIrScbBhqph5altkstCBvdY61KED+OTFoZB4p3Ke15o8xSpv43/LJvIkHkwxuzDsStpTuUlf3IdyJrS6XO0FJX5SMa05O9oga2IeVdzp5kdFbKdIIF3CChUex2rY1qIZgzwIDAQAB",
         policy = "serverManaged", 
      },
   },
}
