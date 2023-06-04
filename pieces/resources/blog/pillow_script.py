# pip3 install pillow
from PIL import Image, ImageDraw, ImageFont

def create_new_image(firstname, lastname, position1, position2, email):
    # 1. Define variables
    font_big = ImageFont.truetype(font_file, 60)
    font_medium = ImageFont.truetype(font_file, 34)
    font_small = ImageFont.truetype(font_file, 28)

    length_firstname = font_big.getlength(firstname)
    length_position1 = font_medium.getlength(position1)
    length_position2 = font_medium.getlength(position2)

    # 2. Create Image Left
    img_left = Image.new( mode = "RGB", size = (width_white, height_total), color = rgb_white )
    draw = ImageDraw.Draw(
        img_left
    )
    
    draw.text((width_white - length_firstname - padding,0), firstname, rgb_green, font=font_big)
    draw.text((width_white - length_position1 - padding,100), position1, rgb_green, font=font_medium)
    draw.text((width_white - length_position2 - padding,140), position2, rgb_green, font=font_medium)

    # 3. Create Image Right
    img_right = Image.new( mode="RGB", size = (width_total, height_total), color = rgb_green)
    draw = ImageDraw.Draw(
        img_right
    )
    draw.text((0+padding,0), lastname, rgb_white, font=font_big)
    draw.text((offset_email_inside_right,100), email, rgb_white, font=font_small)
    draw.text((offset_url_inside_right,130), "www.company.country", rgb_white, font=font_small)
    
    img_logo = Image.open("placeholder.png")
    logo_box=240
    img_logo.thumbnail((logo_box,logo_box), Image.Resampling.LANCZOS)
    img_right.paste(img_logo, (offset_logo_inside_right,10), mask=img_logo)

    # 4. Merge and save
    img = Image.new( mode = "RGB", size = (width_total, height_total), color = rgb_white )
    img.paste(img_left)
    img.paste(img_right, (width_white,0))
    img.save(export_filename)

if __name__ == "__main__":
    # Image Dimensions
    height_total = 262
    width_total = 1062 # arbitrary size
    width_green = int(width_total*0.6)
    width_white = int(width_total*0,4)

    # Colours
    rgb_white=(255,255,255)
    rgb_green=(70,90,90)

    # Placing Text offsets & padding
    offset_email_inside_right = 20
    offset_url_inside_right = offset_email_inside_right
    offset_logo_inside_right = 380
    padding=10

    # Misc.
    export_filename = "export.jpg"
    font_file = "DIN Alternate Bold.ttf"

    create_new_image("Firstname", "Lastname", "Role Line 1", "Role Line 2", "myemail@company.country")
