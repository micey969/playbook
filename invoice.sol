/** @title Invoicing Contract */

pragma solidity ^0.4.21;
pragma experimental "v0.5.0";


contract Invoicing {

    address public owner;

    /**
     * Constructor function runs once upon contract creation
     */
    function Invoicing() public {
        owner = msg.sender;
    }

    /**
     * Data Type: Invoice Object
     */
    struct Invoice {
        uint total;
        uint balance;
        bool status;
        mapping (uint256 => Payment) payments;
    }

    /**
     * Data Type: Payment Object
     */
    struct Payment {
        uint amount;
        address sender;
    }

    /**
     * Data Type: Invoices Array
     *
     * Reference each invoice by a number
     */ 
    mapping (uint256 => Invoice) public invoices;
    
     /**
     * Data Type: invoiceAccts Array
     * Holds all created invoices
     */
    uint256[] internal invoiceAccts;

    /**
     * Events
     */
    event PaymentComplete(uint256 _invoiceHash);

    /**
     * Check if owner sent the transaction otherwise reject it
     */
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    /**
     * Register an invoice for payments.
     * 
     * @param _invoiceHash {uint256} - Content hash of the off-chain invoice
     * @param _total {uint} - Total amount owed
     */
    function create(uint256 _invoiceHash, uint _total) public returns (bool) {
        invoices[_invoiceHash].total = _total;
        invoices[_invoiceHash].status = false;
        invoices[_invoiceHash].balance = 0;
        invoiceAccts.push(_invoiceHash) -1;
        return true;
    }

    /**
     * Pay an invoice.
     *
     * @dev Create payment, and update invoice balance.
     * @param _invoiceHash {uint256} - Content hash of the off-chain invoice
     * @param _paymentHash {uint256} - Content hash of the off-chain payment
     * @return {bool} - True indicates operation was successful
     *
     */
    function pay(uint256 _invoiceHash, uint256 _paymentHash) public payable returns (bool) {
        invoices[_invoiceHash].payments[_paymentHash].sender = msg.sender;
        invoices[_invoiceHash].payments[_paymentHash].amount = msg.value;
        invoices[_invoiceHash].balance += msg.value;
        if (invoices[_invoiceHash].balance >= invoices[_invoiceHash].total) {
            invoices[_invoiceHash].status = true;
            emit PaymentComplete(_invoiceHash);
        }
        return true;
    }

    /**
     * Open a dispute against the organisation for an invoice.
     *
     * @param _invoiceHash {uint256} - Content hash of the off-chain invoice
     * @param _claim {uint256} - Content hash of the off-chain claim
     *
     * what exactly is a dispute? How can we programmably solve it??
     */
    function dispute(uint256 _invoiceHash, uint256 _claim) public {

    }

    /**
     * Return all payments towards an invoice in the event
     * the organisation loses a dispute.
     *
     * @notice Will be an attractive attack vector 
     * @param _invoiceHash {uint256} - Content hash of the off-chain invoice
     * @param _client {uint256} - Address of
     */
    function refund(uint256 _invoiceHash, address _client) public {
        _client.transfer(invoices[_invoiceHash].balance);
        remove(_invoiceHash);

    }
    
    /**
     * Makes an Invoice  null and void in case of errors 
     *
     * @param _invoiceHash {uint256} - Content hash of the off-chain invoice
     */
    function remove(uint256 _invoiceHash) public returns (bool){
        delete(invoices[_invoiceHash]);
        return true;
    }
    
    /**
     * Displays a list of created Invoice numbers
     */
    function getInvoices() view public returns (uint256[]) {
        return invoiceAccts;
    }
    
    /**
     * Gives a count of created Invoice records
     */
    function countInvoices() view public returns (uint) {
        return invoiceAccts.length;
    }
}