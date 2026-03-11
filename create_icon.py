import base64

# 创建一个简单的粉色爪爪图标 (1024x1024)
# 使用Python的PIL库生成

try:
    from PIL import Image, ImageDraw
    import os
    
    # 创建1024x1024的图像
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 粉色配色
    pink = (255, 105, 180)  # 粉色
    dark_pink = (255, 20, 147)  # 深粉色
    
    # 绘制主掌 (圆形)
    center_x, center_y = size // 2, size // 2 + 50
    draw.ellipse([center_x - 250, center_y - 250, center_x + 250, center_y + 250], fill=pink)
    
    # 绘制4个脚趾 (椭圆形)
    toe_positions = [
        (center_x - 280, center_y - 280),  # 左上
        (center_x + 80, center_y - 320),  # 右上
        (center_x - 320, center_y - 80),  # 左下
        (center_x + 120, center_y - 80),  # 右下
    ]
    
    for tx, ty in toe_positions:
        draw.ellipse([tx - 120, ty - 140, tx + 120, ty + 140], fill=pink)
    
    # 添加高光效果
    draw.ellipse([center_x - 150, center_y - 150, center_x + 50, center_y + 50], fill=(255, 182, 193, 100))
    
    # 保存不同尺寸
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    
    base_path = '/Users/wubin/StarPetApp/android/app/src/main/res'
    
    for folder, s in sizes.items():
        resized = img.resize((s, s), Image.LANCZOS)
        path = f"{base_path}/{folder}/ic_launcher.png"
        resized.save(path, 'PNG')
        print(f"Created: {path}")
    
    print("Icon created successfully!")
    
except ImportError:
    print("PIL not installed, creating placeholder...")
    # 创建一个简单的占位符
    import struct
    import zlib
    
    # 简单的32x32 PNG (粉色方块)
    def create_png():
        width, height = 32, 32
        raw_data = b''
        for y in range(height):
            raw_data += b'\x00'  # filter byte
            for x in range(width):
                raw_data += bytes([255, 105, 180, 255])  # RGBA pink
        
        def png_chunk(chunk_type, data):
            chunk = chunk_type + data
            return struct.pack('>I', len(data)) + chunk + struct.pack('>I', zlib.crc32(chunk) & 0xffffffff)
        
        png_signature = b'\x89PNG\r\n\x1a\n'
        ihdr = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
        
        compressed = zlib.compress(raw_data)
        
        return png_signature + png_chunk(b'IHDR', ihdr) + png_chunk(b'IDAT', compressed) + png_chunk(b'IEND', b'')
    
    png_data = create_png()
    base_path = '/Users/wubin/StarPetApp/android/app/src/main/res'
    
    for folder in ['mipmap-mdpi', 'mipmap-hdpi', 'mipmap-xhdpi', 'mipmap-xxhdpi', 'mipmap-xxxhdpi']:
        path = f"{base_path}/{folder}/ic_launcher.png"
        with open(path, 'wb') as f:
            f.write(png_data)
        print(f"Created placeholder: {path}")
