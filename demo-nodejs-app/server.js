express = require('express')
const app = express();
const host = "0.0.0.0";
const port = 3000;

app.use(function (req, res, next) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Credentials', true);
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
    res.header('Access-Control-Allow-Methods', 'GET');
    next();
});

function calculatePrimes(iterations, multiplier) {
    var primes = [];
    for (var i = 0; i < iterations; i++) {
        var candidate = i * (multiplier * Math.random());
        var isPrime = true;
        for (var c = 2; c <= Math.sqrt(candidate); ++c) {
            if (candidate % c === 0) {
                // not prime
                isPrime = false;
                break;
            }
        }
        if (isPrime) {
            primes.push(candidate);
        }
    }
    return primes;
}

const getPrimes = async (req, res) => {
    const multiplier = 1000000000;
    let iteration = Math.ceil(Math.random() * (500 - 100) + 100);
    let result = await calculatePrimes(iteration, multiplier);
    res.json({"Iterations": iteration, "Multiplier": multiplier, "Primes": result});
}

app.get('/', getPrimes);

app.get('*', (req, res) => {
    res.send('404').status(404).end();
});

app.listen(port, host, () => {
    console.log(`Demo app listening at http://${host}:${port}`);
});