// ==================== 静态数据 ====================

// 宠物类型
class PetTypes {
  static const List<String> types = ['猫', '狗', '兔子', '仓鼠', '鸟', '鱼', '乌龟', '其他'];
  
  static const List<Map<String, String>> breeds = [
    {'type': '猫', 'breed': '英短'},
    {'type': '猫', 'breed': '美短'},
    {'type': '猫', 'breed': '布偶'},
    {'type': '猫', 'breed': '波斯'},
    {'type': '猫', 'breed': '暹罗'},
    {'type': '猫', 'breed': '中华田园猫'},
    {'type': '狗', 'breed': '柯基'},
    {'type': '狗', 'breed': '金毛'},
    {'type': '狗', 'breed': '拉布拉多'},
    {'type': '狗', 'breed': '哈士奇'},
    {'type': '狗', 'breed': '泰迪'},
    {'type': '狗', 'breed': '比熊'},
    {'type': '狗', 'breed': '萨摩耶'},
    {'type': '狗', 'breed': '中华田园犬'},
    {'type': '兔子', 'breed': '垂耳兔'},
    {'type': '兔子', 'breed': '狮子兔'},
    {'type': '兔子', 'breed': '熊猫兔'},
    {'type': '仓鼠', 'breed': '金丝熊'},
    {'type': '仓鼠', 'breed': '银狐'},
    {'type': '仓鼠', 'breed': '布丁'},
  ];
  
  static const List<String> colors = ['白色', '黑色', '金色', '灰色', '棕色', '橘色', '三花', '奶牛', '其他'];
  static const List<String> features = ['粘人', '活泼', '安静', '聪明', '调皮', '忠诚', '胆小', '好奇'];
  static const List<String> genders = ['弟弟', '妹妹'];
}

// 用户角色
class UserRoles {
  static const List<String> roles = ['宠物主人', '上门喂养', '云养宠', '宠物店', '流浪动物救助'];
}

// 商场数据
class MallData {
  static const List<Map<String, dynamic>> malls = [
    {'name': '宠物之星', 'city': '杭州', 'address': '西湖区文一路100号', 'phone': '0571-88888888', 'rating': 4.8, 'tags': ['宠物食品', '宠物玩具'], 'lat': 30.2741, 'lng': 120.1551},
    {'name': '萌宠之家', 'city': '杭州', 'address': '拱墅区湖墅南路200号', 'phone': '0571-87777777', 'rating': 4.6, 'tags': ['宠物美容', '宠物寄养'], 'lat': 30.3120, 'lng': 120.1650},
    {'name': '汪星人乐园', 'city': '杭州', 'address': '滨江区江南大道500号', 'phone': '0571-86666666', 'rating': 4.9, 'tags': ['宠物游泳', '宠物培训'], 'lat': 30.2084, 'lng': 120.2093},
    {'name': '喵星人工作室', 'city': '杭州', 'address': '上城区平海路150号', 'phone': '0571-85555555', 'rating': 4.7, 'tags': ['宠物美容', '宠物摄影'], 'lat': 30.2489, 'lng': 120.1658},
    {'name': '宠物医院', 'city': '南京', 'address': '鼓楼区中山路200号', 'phone': '025-83333333', 'rating': 4.8, 'tags': ['宠物医疗', '疫苗'], 'lat': 32.0603, 'lng': 118.7969},
    {'name': '爱宠宠物店', 'city': '南京', 'address': '秦淮区夫子庙街50号', 'phone': '025-82222222', 'rating': 4.5, 'tags': ['宠物食品', '宠物玩具'], 'lat': 32.0170, 'lng': 118.7876},
    {'name': '萌宠王国', 'city': '南京', 'address': '玄武区长江路100号', 'phone': '025-81111111', 'rating': 4.7, 'tags': ['宠物美容', '宠物寄养'], 'lat': 32.0603, 'lng': 118.7969},
    {'name': '汪汪宠物生活馆', 'city': '南京', 'address': '建邺区河西大街300号', 'phone': '025-80000000', 'rating': 4.6, 'tags': ['宠物游泳', '宠物培训'], 'lat': 32.0650, 'lng': 118.7780},
  ];
}

// 草坪数据
class LawnData {
  static const List<Map<String, dynamic>> lawns = [
    {'name': '西湖公园', 'city': '杭州', 'address': '西湖区西湖风景名胜区', 'rating': 4.9, 'tags': ['草坪大', '狗狗多', '免费'], 'lat': 30.2468, 'lng': 120.1486, 'hours': '全天'},
    {'name': '钱江新城公园', 'city': '杭州', 'address': '上城区钱江新城', 'rating': 4.7, 'tags': ['设施完善', '有饮水点'], 'lat': 30.2431, 'lng': 120.2105, 'hours': '6:00-22:00'},
    {'name': '滨江公园', 'city': '杭州', 'address': '滨江区江南大道', 'rating': 4.6, 'tags': ['跑道', '夜间开放'], 'lat': 30.2084, 'lng': 120.2093, 'hours': '全天'},
    {'name': '白鹭湾湿地公园', 'city': '杭州', 'address': '余杭区白鹭湾', 'rating': 4.8, 'tags': ['环境好', '野餐区'], 'lat': 30.3412, 'lng': 120.0987, 'hours': '6:00-20:00'},
    {'name': '玄武湖公园', 'city': '南京', 'address': '玄武区玄武门', 'rating': 4.9, 'tags': ['历史悠久', '草坪大'], 'lat': 32.0603, 'lng': 118.7969, 'hours': '6:00-22:00'},
    {'name': '中山陵风景区', 'city': '南京', 'address': '玄武区钟山风景区', 'rating': 4.8, 'tags': ['空气好', '爬山'], 'lat': 32.0650, 'lng': 118.8596, 'hours': '6:30-18:30'},
    {'name': '绿博园', 'city': '南京', 'address': '建邺区扬子江大道', 'rating': 4.7, 'tags': ['植物多', '遛狗圣地'], 'lat': 32.0187, 'lng': 118.7298, 'hours': '8:00-18:00'},
    {'name': '紫金山公园', 'city': '南京', 'address': '玄武区钟山', 'rating': 4.6, 'tags': ['自然环境', '登山'], 'lat': 32.0650, 'lng': 118.8780, 'hours': '全天'},
  ];
}

// 初始动态数据
class InitialPosts {
  static const List<Map<String, dynamic>> posts = [
    {'content': '今天带豆豆去公园玩，它好开心啊！🐕', 'time': '2026-03-11 15:30', 'likes': 12},
    {'content': '咪咪今天第一次尝试吃猫罐头，太可爱了！🐱', 'time': '2026-03-10 10:20', 'likes': 25},
    {'content': '新买的宠物玩具到了，俩孩子玩得不亦乐乎', 'time': '2026-03-09 18:45', 'likes': 8},
  ];
}
