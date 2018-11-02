pragma solidity ^0.4.25;

contract SberbankCrypta{
    
    address owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function SberbankCrypta(){
        owner = msg.sender;
    }
    
    string public constant name = "Sberbank Coin Token";
    string public constant symbol = "SCT";
    uint32 public constant decimals = 18;

    address public constant bankAcc = 0x583031d1113ad414f02576bd6afabfb302140225;
    
    mapping (address => uint) balances;
    
    function balanceOf(address _owner) public constant returns (uint balance){
        return balances[_owner];
    }
    function transfer(address _to, uint _value) public returns (bool success){
        if(balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]){
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
        }
        return false;
    }
    function transferFrom(address _from, address _to, uint _value) public returns (bool success){
        if(balances[_from] >= _value && balances[_to] + _value >= balances[_to]){
            balances[_from] -= _value;
            balances[_to] += _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }
    function approve(address _spender, uint _value) public returns (bool success){
        return false;
    }
    function allowance(address _owner, address _spender) public constant returns (uint remainig){
        return 0;
    }
    function mint(address _to, uint _value) public {
       // assert(totalSupply + _value >= totalSupply && balances[_to] + _value >= balances[_to]);
        balances[_to] += _value;
//totalSupply += _value;
    }
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _ownerm, address indexed _spender, uint _value);
    

    uint private PERIOD = 1 minutes;
    uint private constant CREDITRATE = 10;
    uint private constant DEPOSITRATE = 5;
    
    
     modifier  checkInBlackList(address _clientWallet) { // модификатор на проверку принадлежности blackList
        require(list[_clientWallet].creditRating >= 0);
        _;
    }

    struct List
    {
        address clientWallet;
        uint sumDebt; // Сумма задолженности
        uint dateDef; //Дата дефолта, попадания в блэклист
        int creditRating; //Кредитный рейтинг
    }
    
    mapping(address => List) private list;
    
    function _addToList(address _clientWallet, int _creditRating) private checkInBlackList(_clientWallet) { 
        // добавление в whiteList нового клиента, этот метод также изменяет кредитный рейтинг
        list[_clientWallet] = List(_clientWallet, 0, 0 , _creditRating); 
    }
    
    
   function _addToBlackList(address _clientWallet, uint _sumDebt, uint _dateDef) private{  // добавление в blackList 
        list[_clientWallet] = List(_clientWallet, _sumDebt ,_dateDef, -1);
    }
       function _getRating(address _clientWallet) private constant returns(int){
        return list[_clientWallet].creditRating;
    }

    struct Deposit {
        uint timeBegin;
        uint timeReturn;
        uint duration;
        uint summa;
        address clientWallet;
    }
    Deposit[] private depositArray;
    mapping(address => uint) idDeposit; //ключ - значение для быстрого поиска депозита 
 
    function GetDeposit(address _clientWallet, uint _sum, uint _duration)public  //функция  добавления депозита
    {
        mint(_clientWallet,_sum);
        //CheckCapital(_sum,false);
        transferFrom(_clientWallet,bankAcc,_sum);
        Deposit memory deposit;
        deposit.timeBegin = now;
        deposit.timeReturn = deposit.timeBegin + (_duration * PERIOD);
        deposit.summa = _sum + ((_sum * _duration * DEPOSITRATE)/100 + (_sum * _duration * DEPOSITRATE)%100);
        deposit.duration = _duration;
        deposit.clientWallet = _clientWallet;
        idDeposit[_clientWallet] = (depositArray.push(deposit) - 1);
    }

function Refund(address _clientWallet) public // возврат средств
    {
        if(now >= depositArray[idDeposit[_clientWallet]].timeReturn){
            CheckCapital(depositArray[idDeposit[_clientWallet]].summa,true);
            transferFrom(bankAcc,_clientWallet,depositArray[idDeposit[_clientWallet]].summa);
            depositArray[idDeposit[_clientWallet]].summa = 0;
        }
    }
    
        struct Credit {
        uint timeBegin;
        uint timeReturn;
        uint duration;
        uint summa;
        address clientWallet;
    } 
    
    Credit[] private creditArray;
    mapping(address=>uint) clientCredits; 
    mapping(address=>uint[]) idCredit;
    
     event GetCreditComplete(address indexed _clientWallet,  bool _checkComplete,  string _checkError); 
    
    function GetCredit(address _clientWallet, uint _sum, uint _duration) public checkInBlackList(msg.sender) //получение кредита
    {
        if (idCredit[_clientWallet].length < 5) // максимальное кколичество кредитов на одного клиента
        {
            
        int rate = int(_sum) * int(_duration) * int(PERIOD)/60;
        if ((list[_clientWallet].clientWallet != _clientWallet) && (rate < 10000))
        {
       _addToList(_clientWallet, rate); // добавление в массив вайтлиста
       //CheckCapital(_sum,true);
            transferFrom(bankAcc, _clientWallet, _sum);
              
        Credit memory credit;
        credit.timeBegin = now;
        credit.timeReturn = credit.timeBegin + (_duration * PERIOD);
        credit.summa = _sum + (_sum * _duration * CREDITRATE) / 100 + (_sum * _duration * CREDITRATE) % 100;
        credit.duration = _duration;
        credit.clientWallet = _clientWallet;
        idCredit[_clientWallet].push((creditArray.push(credit) - 1)) - 1; 
        GetCreditComplete(msg.sender, true, "Успешное выполнение");
        }
        else 
        { 
            rate += _getRating(_clientWallet); //изменение рейтинга вайтлиста, если уже есть кредиты
            if (rate < 10000)
            {
                _addToList(_clientWallet, rate);
                //CheckCapital(_sum,true);
                transferFrom(bankAcc, _clientWallet, _sum);
                Credit memory credit_else;
                credit_else.timeBegin = now;
                credit_else.timeReturn = credit_else.timeBegin + (_duration * PERIOD);
                credit_else.summa = _sum + (_sum * _duration * CREDITRATE) / 100 + (_sum * _duration * CREDITRATE) % 100;
                credit_else.duration = _duration;
                credit_else.clientWallet = _clientWallet;
                idCredit[_clientWallet].push((creditArray.push(credit_else) - 1)) - 1;
                GetCreditComplete(msg.sender, true, "Успешное выполнение");
            }
            else 
            {
                GetCreditComplete(msg.sender, false, "Превышение рейтинга, выдача кредита невозможна");
                throw;
            }
        }
        }
        else 
        {
            GetCreditComplete(msg.sender, false, "Невозможна выдаа кредита, количество превысило допустимое");
            throw;
        }
    }
    
    function CreditPay( address _clientWallet, uint _sum, uint _idCredit) public{
        //проверка на просрочку
        if (creditArray[idCredit[_clientWallet][_idCredit]].summa >= _sum)
        {
            transferFrom(_clientWallet, bankAcc, _sum);
            creditArray[idCredit[_clientWallet][_idCredit]].summa -= _sum;
            if (creditArray[idCredit[_clientWallet][_idCredit]].summa == 0) //обнуление кредитного рейтинга при полном гашении
            {
                _addToList(_clientWallet, 0);
            }
        }
        
    }
    
    function GetClientCredits(address _clientWallet, uint _idCredit) public constant returns(uint) { //проверка суммы долга по кредиту
        return creditArray[idCredit[_clientWallet][_idCredit]].summa;
    }
    
        function test(address _clientWallet) public constant returns(uint[5]) { // получени информации о кредитах клиента
            uint[5] s;
            for (uint i=0;i<idCredit[_clientWallet].length ; i++)
            {
                s[i] = idCredit[_clientWallet][i];
            }
            for (uint j=idCredit[_clientWallet].length; j < 5; j++)
            {
                s[j] = 999;
            }
        return s;
    }
    uint burnableCoin = 0;
    function CheckCapital(uint _sum, bool _flag)private { // имитация недостающих монет
        //flag = true when credit or refund case
        if(_sum >= balances[bankAcc] && _flag){
            uint delta = _sum - balances[bankAcc];
            mint(bankAcc, delta);
            burnableCoin += delta;
        }
        else if(_sum > burnableCoin && !_flag){
            burnableCoin = 0;
            balances[bankAcc] -= _sum;
            burnableCoin = 0;
        }
        else if(_sum <= burnableCoin && !_flag){
            if(balances[bankAcc] >= _sum){
                balances[bankAcc] -= _sum;
                burnableCoin -= _sum;
            }
        }
    }



}