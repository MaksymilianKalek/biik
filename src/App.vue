<template>
  <div class="container pt-5">
    <h1>Kalek Gnusowski - {{ account }}</h1>
    <form @submit="onSubmit">
      <div class="row mt-5 mb-3">
        <div class="col">
          <input id="productName" type="text" class="form-control" v-model="productName"/>
        </div>
        <div class="col">
          <button type="submit" class="btn btn-primary">Add Product</button>
        </div>
      </div>
    </form>
    <h2>Shopping list</h2>
    <table class="table">
      <thead>
      <tr>
        <th scope="col">#</th>
        <th scope="col">Product name</th>
        <th scope="col">Created by</th>
        <th scope="col"></th>
        <th scope="col"></th>
      </tr>
      </thead>
      <tbody id="productList">
      <tr v-for="(product, index) in products" :key="product.id">
        <td class="align-middle fw-bold">{{ index + 1 }}</td>
        <td class="align-middle" :class="{ 'cross' : product.crossed}">{{ product.name }}</td>
        <td class="align-middle" :class="{ 'cross' : product.crossed}">{{ product.owner }}</td>
        <td class="align-middle">
          <button v-if="!product.crossed" type="button" class="btn btn-success" @click="crossProduct(product.id)">Cross out</button>
          <button v-if="product.crossed" type="button" class="btn btn-success" @click="unCrossProduct(product.id)">Un cross</button>
        </td>
        <td class="align-middle">
          <button type="button" class="btn btn-danger" @click="clear(product.id)">Remove</button>
        </td>
      </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import Web3 from "web3/dist/web3.min.js";
import ShoppingList from '@/abis/ShoppingList.json'

export default {
  name: 'App',
  data() {
    return {
      contract: {},
      account: "",
      productCount: 0,
      products: [],
      productName: "",
      isCrossed: false
    }
  },
  async mounted() {
    await this.loadWeb3();
    await this.loadBlockchainData();
  },
  methods: {
    loadWeb3: async function () {
      if (window.ethereum) {
        window.web3 = new Web3(window.ethereum)
        await window.ethereum.enable();
      } else if (window.web3) {
        window.web3 = new Web3(window.web3.currentProvider);
      } else {
        window.alert('Ethereum not supported');
      }
    },
    loadBlockchainData: async function () {
      this.products = [];
      this.productCount = 0;
      const web3 = window.web3;
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];
      const networkId = await web3.eth.net.getId();
      const networkData = ShoppingList.networks[networkId];
      if (networkData) {
        const contract = new web3.eth.Contract(ShoppingList.abi, networkData.address);
        this.contract = contract;
        const productCount = await contract.methods.productCount().call();
        this.productCount = productCount
        for (let i = 1; i <= productCount; i++) {
          const product = await contract.methods.products(i).call();
          if (product.name !== "") {
            this.products = [...this.products, product]
          }
        }
      } else {
        window.alert('Contract not deployed');
      }
    },
    createProduct: function (name) {
      this.contract.methods.createProduct(name).send({from: this.account})
          .once('receipt', () => {
            this.loadBlockchainData();
          })
    },
    onSubmit: function (event) {
      event.preventDefault();
      const name = this.productName;
      this.createProduct(name);
      this.productName = "";
    },
    crossProduct: function (id) {
      this.contract.methods.crossProduct(id).send({from: this.account})
          .once('receipt', () => {
            this.loadBlockchainData();
          })
    },
    unCrossProduct: function (id) {
      this.contract.methods.unCrossProduct(id).send({from: this.account})
          .once('receipt', () => {
            this.loadBlockchainData();
          })
    },
    clear: function (id) {
      this.contract.methods.clearProduct(id).send({from: this.account})
          .once('receipt', () => {
            this.loadBlockchainData();
          })
    }
  }
}
</script>

<style scoped>
.cross {
  text-decoration: line-through;
}
</style>