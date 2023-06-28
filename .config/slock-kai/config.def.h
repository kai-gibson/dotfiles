/* user and group to drop privileges to */
static const char *user  = "nobody";
static const char *group = "nobody";

static const char *colorname[NUMCOLS] = {
	[INIT] =   "black",     /* after initialization */
	[INPUT] =  "#92a09e",   /* during input */
	[FAILED] = "#CC3333",   /* wrong password */
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;

/* default message */
static const char * message = "With the jawbone of an ass, \n\nheaps upon heaps. \n\nWith the jawbone of an ass I have killed a thousand men.";

/* time in seconds before the monitor shuts down */
static const int monitortime = 5;

/* text color */
static const char * text_color = "white";

/* text size (must be a valid size) */
static const char * font_name = "-b&h-lucidabright-medium-i-normal--34-240-100-100-p-194-iso8859-15";
