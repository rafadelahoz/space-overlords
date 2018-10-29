package;

import extension.share.Share;

class ShareManager
{
    static var initialized : Bool = false;

    public static function share(msg : String, ?savedImagePath : String = null)
    {
        if (!initialized)
		{
            initialized = true;
			Share.init(Share.TWITTER);
		}

		var imagePath : String = null;
        if (savedImagePath == null)
            imagePath = Screenshot.take();
        else if (savedImagePath != null)
            imagePath = savedImagePath;

		Share.share(msg, null, imagePath);
    }
}
