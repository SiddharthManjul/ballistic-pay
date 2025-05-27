# PROJECT MANAGEMENT: BALLISTIC PAY

### Project Requirements:
<ul>
  <li>Oracles: Price Feed direct access || Chainlink Functions integrated with custom Oracle || Data Streams</li>
  <li>Zero Knowledge Proofs: Circom || Off-chain proof generation through Rust libraries such as Bellman or Arkworks</li>
  <li>Cross Chain Implementation: Wormhole || Chainlink</li>
  <li>Liquidity: Uniswap || Balancer || Curve Finance</li>
  <li>Staking: Lido Finance || Aave Protocol || Jito Network</li>
  <li>Lending/Borrowing: Aave Protocol</li>
  <li>Note: These requirements are subject to change.</li>
</ul>

### User Flow:
<ul>
  <li>Login: Zero Knowledge based Wallet built on the principle of Embedded Wallets. User will login using this wallet, addresses, private keys, phrases and the portfolio will be managed internally.</li>
  <br />
  <li>Dashboard: Dashboard is partitioned between 2 different entities, Payer & Payee. Since Ballistic Pay is more focused on B2B, so we will target Web3 Startups & established companies initially and we'll provide salary payouts as a Service.</li>
  <ul>
    <li>Payer Dashboard: 
      <ul>
        <li>Top Bar: Total Payable Amount || Total Number of Employees || Next Payroll Date || Pending Approvals || Total Deductions || Current Balance</li>
        <li>Employee Payroll Table: Name, Role, Salary (Gross), Deductions, Net Pay, Status, Payment Date, Token Currency. <span>Included Action Buttons: View Payslip, Edit Salary, Send Payment, View Proofs.</span></li>
        <li>Detailed Employee View (on click)
          <ul>
            <li>Basic Info: Name, Role, Wallet Address, Bank info (for fiat).</li>
            <li>Monthly Breakdown: Gross Pay, Tax Withheld, Benefits/Perks, Other deductions, Net Pay.</li>
            <li>Payment History (downloadable playsip)</li>
            <li>Proof of Payment (zk-proof link)</li>
            <li>Performance Metrics (optional)</li>
          </ul>
        </li>
      </ul>
    </li>
    <li>Payee: Payee will also have the price graph available for all the tokens listed on the platform against USDT. Their dashboard will have a section which will show the amount they have in the wallet. A section will show all the received transactions & one for send transaction will be there also. All the payment receipts will also be indexed through the dashboard. Multiple investment options will be available such as Staking, Lending and other safe investment schemes. The dashboard will also show total investments & capital gains with integrated portfolio management system.</li>
  </ul>
  <li>Flow: Depending upon the tokens available in payer's account, he/she will select a token to pay the amount to all the payees. Once the token is selected, the system will show the list of all the payees with their details and amount they will receive. If a new payee comes, payer will have the option to add the details of this payee and the credentials will be verified through Zero Knowledge Proofs. Once the list is ready, the payer will be able to initiate the transaction through a batch transaction. This is a batch transaction so all the payee will receive amount in one transaction which is highly efficient in terms of gas. Once the transaction is successful, the receipt will be generated & sent to the payee. The receipts will be available on-chain with some data in encrypted format & all the receipts will be indexed on our platform.</li>
</ul>

### ZK Integration:
<p>Allow employers to prove salary payments occurred to specific employees without revealing the amount, using zero-knowledge proofs.</p>
<ul>
  <li>ZK Circuit – Generate a proof that a payment happened with hidden amount.</li>
  <li>Commitment Scheme – Hide the actual salary value (amount).</li>
  <li>Merkle Tree or Nullifier – Prevent double claims and prove inclusion.</li>
  <li>On-chain Verifier – Smart contract to verify ZK proof without knowing the amount.</li>
</ul>