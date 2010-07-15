Postinius is a lightweight, Ruby-licious wrapper for the
scarred and battle-hardened JavaMail API.

Postinius is a JRuby-only gem, and was written because we needed a
well-tested mail library that handles multiple languages and character 
sets under JRuby.

You can use it to parse emails:

    require 'postinius'
    require 'postinius/message'

    email = <<EndOfEmail
    From: Don Werve <don@madwombat.com>
    To: support@madwombat.com
    Subject: Important message.

    Hello, world!
    EndOfEmail

    message = Postinius::Message.new(email)
    puts message.subject
    puts message.from.
    # => "Important message."

Or to create them from scratch:

    message = Postinius::Message.new do
	subject "Re: Important message."
	from "support@madwombat.com"
	to "don@madwombat.com"
	text "The world is currently busy."
    end

It supports all manner of multipart messages and attachments:

    message = Postinius::Message.new do
	subject "Re: Important message."
	from "don@madwombat.com"
	to "support@madwombat.com"
	text "Oh... well, is Mars available?"
	html "Oh... well, is <b>Mars</b> available?"
	attach :file => 'haynes-manual-for-spirit-rover.pdf'
    end

...and even handles foreign character sets just fine:

    require 'postinius'
    require 'postinius/message'

    email = <<EndOfEmail
    From: =?UTF-8?B?44OJ44Oz44O744Ov44O844OT?= <don@madwombat.com>
    To: root@madwombat.com
    Message-ID: <52541967-d44d-4f0d-8569-a651d76138db@tardis.local>
    Subject: =?UTF-8?B?44GT44KT44Gr44Gh44Gv54Gr5pif77yB?=
    MIME-Version: 1.0
    Content-Type: text/plain; charset=UTF-8
    Content-Transfer-Encoding: base64

    5YWI44Gr6YCB5L+h44GX44Gf44Oe44OL44Ol44Ki44Or44Gn44Ot44Oc44OD44OI5o6i5p+76LuK
    44K544OU44Oq44OD44OI44GM55u044KM44KL44KI44GG44Gr44Gq44KL44Go5oCd44GE44G+44GZ
    44CC
    EndOfEmail

    message = Postinius::Message.new(email)
    puts message.from
    # => "ドン・ワービ <don@madwombat.com>"
    puts message.subject
    # => "こんにちは火星！"

Additional documentation will be forthcoming. :)

Postinius is licensed under the Apache 2.0 Open Source License; see the
LICENSE file for details, and was written for [Mad Wombat 
Software](http://www.madwombat.com)
