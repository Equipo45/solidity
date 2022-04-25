// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


// TONI,I123I12,23
// EESP,TY76545,32
// HYUO,H654543,56
// KIWI,K786567,76


contract votacion{

    address public owner;

    constructor () public{

        owner=msg.sender;

    }

    //Relacion nombre hash

    mapping(string => bytes32) id_Candidato;

    //Relacion candidato votos
    mapping(string => uint)candidato_Votos;
    //Lista candidatos
    string[] lista_candidatos;

    bytes32[] votantes;

    function almacenarDatos(string memory _nombre,string memory _id,uint edad)public{
        bytes32 hash_candidato = keccak256(abi.encodePacked(_nombre,_id,edad));

        id_Candidato[_id]=hash_candidato;

        lista_candidatos.push(_nombre);
    }

    function verCandidatos()public view returns(string[] memory){
        return lista_candidatos;
    }


    function consultarVotos(string memory _candidato)public view returns(uint){
        return candidato_Votos[_candidato];
    }

    function votarCandidato(string memory nombre_Candidatos)public{
        //msg.sender es el que activa o el primero en interactuar con el smart cont
        bytes32 hash_votante = keccak256(abi.encodePacked(msg.sender));
        
        //Verificamos que no haya votado ya

        for(uint i=0;i<votantes.length;i++){
            require(votantes[i]!= hash_votante,"Ya has votado");
        }

        votantes.push(hash_votante);
        candidato_Votos[nombre_Candidatos]++;
        
    }


//Funcion auxiliar
   function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function verResultados()public view returns(string memory){
        string memory resultados;
        for(uint i=0;i<lista_candidatos.length;i++){

            resultados = string(abi.encodePacked(resultados,"||",lista_candidatos[i],":",uint2str(candidato_Votos[lista_candidatos[i]])));
            
        }

        return resultados;
    }

    function Ganador()public view returns(string memory){
        string memory ganador=lista_candidatos[0];
        bool flag ;
        for(uint i=1;i<lista_candidatos.length;i++){
            if(candidato_Votos[lista_candidatos[i]]>candidato_Votos[ganador]){
                ganador=lista_candidatos[i];
                flag = false;
            }
            else{
                if(candidato_Votos[lista_candidatos[i]]==candidato_Votos[ganador]){
                    flag = true;
                }
                else{
                    flag = false;
                }
            }
            
        }

        if(flag){
            ganador="Dos candidatos han empatado";
        }

        return ganador;
    }





}