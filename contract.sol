pragma solidity ^0.4.25;

contract SberbankCrypta{
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
    

    uint PERIOD = 10 seconds;
    uint CREDITRATE = 10;
    uint DEPOSITRATE = 5;
    
    
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
    mapping(address => uint) idDeposit;
 
    function GetDeposit(address _clientWallet, uint _sum, uint _duration)public 
    {
        mint(_clientWallet,_sum);
        transferFrom(_clientWallet,bankAcc,_sum);
        Deposit deposit;
        deposit.timeBegin = now;
        deposit.timeReturn = deposit.timeBegin + (_duration * PERIOD);
        deposit.summa = _sum + ((_sum * _duration * DEPOSITRATE)/100 + (_sum * _duration * DEPOSITRATE)%100);
        deposit.duration = _duration;
        deposit.clientWallet = _clientWallet;
        idDeposit[_clientWallet] = (depositArray.push(deposit) - 1);
    }

function Refund(address _clientWallet) public
    {
        if(now >= depositArray[idDeposit[_clientWallet]].timeReturn){
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
    
    
    function GetCredit(address _clientWallet, uint _sum, uint _duration) public
    {
        transferFrom(bankAcc, _clientWallet, _sum);
        Credit credit;
        uint timeBegin = now;
        credit.timeBegin = now;
        credit.timeReturn = credit.timeBegin + (_duration * PERIOD);
        credit.summa = _sum + ((_sum * _duration *CREDITRATE)/100) + ((_sum * _duration *CREDITRATE)%100);
        credit.duration = _duration;
        credit.clientWallet = _clientWallet;
        clientCredits[_clientWallet] = creditArray.push(credit) - 1;
    }
    
    function CreditPay( address _clientWallet, uint _sum, uint _idCredit) public{
        //проверка на просрочку
        if (creditArray[clientCredits[_clientWallet]].summa >= _sum)
        {
            transferFrom(_clientWallet, bankAcc, _sum);
            creditArray[clientCredits[_clientWallet]].summa -= _sum;
            if (creditArray[clientCredits[_clientWallet]].summa == 0) //обнуление кредитного рейтинга при полном гашении
            {
                _addToList(_clientWallet, 0);
            }
        }
        
    }
    
    function GetClientCredits(address _clientWallet) public constant returns(uint) {
        return creditArray[clientCredits[_clientWallet]].summa;
    }
    
    
    
}


