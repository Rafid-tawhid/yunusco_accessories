class UserModel {
  UserModel({
      num? userId, 
      String? userName, 
      String? loginName, 
      String? password, 
      num? roleId, 
      bool? isActive, 
      dynamic passwordChanged, 
      dynamic customerCode, 
      String? userEmail, 
      String? lastLogin, 
      num? rBOId, 
      num? businessUnitId, 
      dynamic iDCardNo, 
      dynamic isDeptHead, 
      dynamic isMarketingPerson, 
      bool? hasAuthority, 
      dynamic customerGroupId,}){
    _userId = userId;
    _userName = userName;
    _loginName = loginName;
    _password = password;
    _roleId = roleId;
    _isActive = isActive;
    _passwordChanged = passwordChanged;
    _customerCode = customerCode;
    _userEmail = userEmail;
    _lastLogin = lastLogin;
    _rBOId = rBOId;
    _businessUnitId = businessUnitId;
    _iDCardNo = iDCardNo;
    _isDeptHead = isDeptHead;
    _isMarketingPerson = isMarketingPerson;
    _hasAuthority = hasAuthority;
    _customerGroupId = customerGroupId;
}

  UserModel.fromJson(dynamic json) {
    _userId = json['UserId'];
    _userName = json['UserName'];
    _loginName = json['LoginName'];
    _password = json['Password'];
    _roleId = json['RoleId'];
    _isActive = json['IsActive'];
    _passwordChanged = json['PasswordChanged'];
    _customerCode = json['CustomerCode'];
    _userEmail = json['UserEmail'];
    _lastLogin = json['LastLogin'];
    _rBOId = json['RBOId'];
    _businessUnitId = json['BusinessUnitId'];
    _iDCardNo = json['IDCardNo'];
    _isDeptHead = json['IsDeptHead'];
    _isMarketingPerson = json['IsMarketingPerson'];
    _hasAuthority = json['HasAuthority'];
    _customerGroupId = json['CustomerGroupId'];
  }
  num? _userId;
  String? _userName;
  String? _loginName;
  String? _password;
  num? _roleId;
  bool? _isActive;
  dynamic _passwordChanged;
  dynamic _customerCode;
  String? _userEmail;
  String? _lastLogin;
  num? _rBOId;
  num? _businessUnitId;
  dynamic _iDCardNo;
  dynamic _isDeptHead;
  dynamic _isMarketingPerson;
  bool? _hasAuthority;
  dynamic _customerGroupId;
UserModel copyWith({  num? userId,
  String? userName,
  String? loginName,
  String? password,
  num? roleId,
  bool? isActive,
  dynamic passwordChanged,
  dynamic customerCode,
  String? userEmail,
  String? lastLogin,
  num? rBOId,
  num? businessUnitId,
  dynamic iDCardNo,
  dynamic isDeptHead,
  dynamic isMarketingPerson,
  bool? hasAuthority,
  dynamic customerGroupId,
}) => UserModel(  userId: userId ?? _userId,
  userName: userName ?? _userName,
  loginName: loginName ?? _loginName,
  password: password ?? _password,
  roleId: roleId ?? _roleId,
  isActive: isActive ?? _isActive,
  passwordChanged: passwordChanged ?? _passwordChanged,
  customerCode: customerCode ?? _customerCode,
  userEmail: userEmail ?? _userEmail,
  lastLogin: lastLogin ?? _lastLogin,
  rBOId: rBOId ?? _rBOId,
  businessUnitId: businessUnitId ?? _businessUnitId,
  iDCardNo: iDCardNo ?? _iDCardNo,
  isDeptHead: isDeptHead ?? _isDeptHead,
  isMarketingPerson: isMarketingPerson ?? _isMarketingPerson,
  hasAuthority: hasAuthority ?? _hasAuthority,
  customerGroupId: customerGroupId ?? _customerGroupId,
);
  num? get userId => _userId;
  String? get userName => _userName;
  String? get loginName => _loginName;
  String? get password => _password;
  num? get roleId => _roleId;
  bool? get isActive => _isActive;
  dynamic get passwordChanged => _passwordChanged;
  dynamic get customerCode => _customerCode;
  String? get userEmail => _userEmail;
  String? get lastLogin => _lastLogin;
  num? get rBOId => _rBOId;
  num? get businessUnitId => _businessUnitId;
  dynamic get iDCardNo => _iDCardNo;
  dynamic get isDeptHead => _isDeptHead;
  dynamic get isMarketingPerson => _isMarketingPerson;
  bool? get hasAuthority => _hasAuthority;
  dynamic get customerGroupId => _customerGroupId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['UserId'] = _userId;
    map['UserName'] = _userName;
    map['LoginName'] = _loginName;
    map['Password'] = _password;
    map['RoleId'] = _roleId;
    map['IsActive'] = _isActive;
    map['PasswordChanged'] = _passwordChanged;
    map['CustomerCode'] = _customerCode;
    map['UserEmail'] = _userEmail;
    map['LastLogin'] = _lastLogin;
    map['RBOId'] = _rBOId;
    map['BusinessUnitId'] = _businessUnitId;
    map['IDCardNo'] = _iDCardNo;
    map['IsDeptHead'] = _isDeptHead;
    map['IsMarketingPerson'] = _isMarketingPerson;
    map['HasAuthority'] = _hasAuthority;
    map['CustomerGroupId'] = _customerGroupId;
    return map;
  }

}