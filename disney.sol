pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

//Una cosa es el woner del smart contract y otras el address del smart contract
contract Disney{
    //------------------------------- Declaraciones Iniciales -------------------------
    ERC20Basic private token;
    //Direccion para realizar pagos Owner del contrato
    address payable public owner;
    address public contrato = address(this);
    constructor()public{
        token = new ERC20Basic(10000000);
        owner = payable(msg.sender);
    }

    //Estrcutura para almacenar datos
    struct cliente{

        uint tokens_comprados;
        string[] atracciones_disfrutadas;

    }

    mapping(address => cliente) public Clientes;
    mapping(string => atraccion) public nombre_Atraccion;

    string[] nombre_atracciones;

    //Mapping indentidad historial
    //Historial de atracciones de los clientes por su address
    mapping(address => string[]) cliente_historial; 

    // ------------------------------------ GESTION DE TOKENS --------------------------------

    function PrecioTokens(uint _numTokens) internal pure returns(uint){
        //Conversion de tokens a ethers
        return _numTokens*(1 ether);
    }

    function balanceOf() public view returns(uint){
        //El balance de tokens de el address del contrato
        return token.balanceOf(address(this));
    }

    //Funcion comprar tokens en disney
    //Con payable te quitaran el valor de tu transsacion directamente 
    //No hace falta poner un pay o algo asi
    function ComprarTokens(uint _numTokens) public payable{
        //Cuanto valen los tokens que queremos comrprar
        uint coste = PrecioTokens(_numTokens);
        //El valor que el cliente paga por los tokens, tienes ether suficientes 
        //Por ejemplo slippage insugfieciente       
        require(msg.value >= coste,"Necesitas ams ethers o comprar menos tokens");
        //Ethers del cliente menos ethers  que cuestan los tokens seria un interchange
        //Pagas con un billete de 10 algo de 5
        uint returnValue = msg.value - coste;//Aqui se ve lo que paga el cliente
        payable(msg.sender).transfer(returnValue);
        //Balance disponibles
        //This currenct conract instance
        uint balance = balanceOf();
        //No puedes comprar mas tokens que los que tenga el contrato
        require(_numTokens <= balance,"Compra menos tokens");

        //Tranferimos a la cartera el numero de tokens
        token.transfer(msg.sender,_numTokens);
        //Esta persona tendra asginado sus tokens
        Clientes[msg.sender].tokens_comprados= _numTokens;


    }

    function MisTokens() public view returns(uint){
        //Tokens del que interactua con el contrato
        return token.balanceOf(msg.sender);
    }

    //Funcion para generar mas tokens

    modifier soloDisney(address _dirreccion){
        require(_dirreccion == owner,"Solo lo peude utilizar quien despliega el cotntrato");
        _;
    }
    //Solo se podran utilizar por quien despliegue el contrato
    function GenerarTokens(uint _generados)public soloDisney(msg.sender){
        token.increaseTotalSupply(_generados);
    }

    event subir_atraccion(string);
    event alta_atraccion(string);
    event baja_atraccion(string);
    event anadir_menu(string);

    //Mapping para atracciones

    struct atraccion{
        string  nombre ;
        uint precio;
        bool estado;
    }

    struct menu{
        string nombre;
        uint precio;
    }

    mapping(string => menu) nombre_Menu;


    

    function NuevaAtraccion(string memory _nombre, uint _precio)public soloDisney(msg.sender){
        //No declarar la variable poner directamente la atraccion sin declararla
    
        nombre_Atraccion[_nombre] = atraccion(_nombre,_precio,true);
        nombre_atracciones.push(_nombre);

        emit alta_atraccion(_nombre);
        
    }
    function BajaAtraccion(string memory _nombre)public soloDisney(msg.sender){
        nombre_Atraccion[_nombre].estado=false;
        emit baja_atraccion(_nombre);

    }

    //Visualizar atracciones

    function AtraccionesDisponibles()public view returns(string[] memory){
        return nombre_atracciones;
    }

    function subirseAtraccion(string memory _nombre)public{

        uint precio_atraccion = nombre_Atraccion[_nombre].precio;

        require(nombre_Atraccion[_nombre].estado==true,
                    "Atraccion no preparada para el uso");
        require(precio_atraccion <= MisTokens(),
                    "No tienes tokens sufiecientes");
        //Sender del mensaje a el contrato 
        token.transfer_disney(msg.sender,address(this),precio_atraccion);
        cliente_historial[msg.sender].push(_nombre);

        emit subir_atraccion(_nombre);

            
    }

    function Historial()public view returns(string [] memory){
        return cliente_historial[msg.sender];
    }

    function devolverTokens(uint _cantidad)public payable{
        require(_cantidad > 0 ,"Poner cantidad correcta de tokens");
        require(_cantidad <= MisTokens(),"Cantidad en mano insuficiente" );
        //Devolvemos los tokens y debe recivier ethers
        token.transfer_disney(msg.sender,address(this),_cantidad);

        //El msg sender recive una cantidad de tokens
        //Convertimos coste de tokens a ethers
        payable(msg.sender).transfer(PrecioTokens(_cantidad));
    }

    function anadir_Menu(string memory _nombre,uint _cantidad)public soloDisney(msg.sender){
        nombre_Menu[_nombre]=menu(_nombre,_cantidad);
        emit anadir_menu(_nombre);
    }

    function comprar_menu(string memory _nombre)public{
        require(MisTokens()>= nombre_Menu[_nombre].precio,"Menu demasiado caro para tu bolsillo");
        token.transfer_disney(msg.sender,address(this),nombre_Menu[_nombre].precio);
    }

}