<script lang="ts">
    import { caption } from './stores.js'

    let captionValue: string
    caption.subscribe((value: string) => {
        captionValue = value
    })
</script>

<main>
    <h1>{captionValue}</h1>
    <div class="loader">Loading...</div>
</main>

<style>
    h1 {
        font-family: 'Segoe UI Light', 'Segoe WP Light', device-segoe-light, 'Segoe WP Semilight', 'Segoe UI',
            'Segoe WP', Segoe, Tahoma, Helvetica, Arial, sans-serif;
        font-size: 18pt;
        text-align: center;
        margin: 0;
    }
    .loader,
    .loader:before,
    .loader:after {
      border-radius: 50%;
      width: 2.5em;
      height: 2.5em;
      -webkit-animation-fill-mode: both;
      animation-fill-mode: both;
      -webkit-animation: load7 1.8s infinite ease-in-out;
      animation: load7 1.8s infinite ease-in-out;
    }
    .loader {
      color: #00B7C3;
      font-size: 7px;
      margin: 10px auto;
      position: relative;
      text-indent: -9999em;
      -webkit-transform: translateZ(0);
      -ms-transform: translateZ(0);
      transform: translateZ(0);
      -webkit-animation-delay: -0.16s;
      animation-delay: -0.16s;
    }
    .loader:before,
    .loader:after {
      content: '';
      position: absolute;
      top: 0;
    }
    .loader:before {
      left: -3.5em;
      -webkit-animation-delay: -0.32s;
      animation-delay: -0.32s;
    }
    .loader:after {
      left: 3.5em;
    }
    @-webkit-keyframes load7 {
      0%,
      80%,
      100% {
        box-shadow: 0 2.5em 0 -1.3em;
      }
      40% {
        box-shadow: 0 2.5em 0 0;
      }
    }
    @keyframes load7 {
      0%,
      80%,
      100% {
        box-shadow: 0 2.5em 0 -1.3em;
      }
      40% {
        box-shadow: 0 2.5em 0 0;
      }
    }
</style>
