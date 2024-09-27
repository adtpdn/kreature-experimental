const gameArea = document.getElementById('gameArea');
const boat = document.getElementById('boat');
const bait = document.getElementById('bait');
const throwBaitArea = document.getElementById('throwBait');
const statusDisplay = document.getElementById('status');
const gameInfoDisplay = document.getElementById('gameInfo');
const modal = document.getElementById('menuModal');
const closeModal = document.getElementsByClassName('close')[0];
const openMenuBtn = document.getElementById('openMenu');
const baitSelect = document.getElementById('baitSelect');
const caughtFishList = document.getElementById('caughtFishList');
const sellFishBtn = document.getElementById('sellFish');

let boatX = 180;
let boatY = 170;
let isFishing = false;
let fishShadows = [];
let hookedFish = null;
let money = 0;
let gameTime = 0;
let weather = 'sunny';
let selectedBait = 'worm';
let caughtFish = [];

const fishTypes = {
    'sunny': ['goldfish', 'carp', 'trout'],
    'rainy': ['catfish', 'bass', 'perch'],
    'cloudy': ['salmon', 'pike', 'tuna']
};

const baitEffectiveness = {
    'worm': ['goldfish', 'carp', 'catfish'],
    'lure': ['bass', 'pike', 'trout'],
    'fly': ['salmon', 'perch', 'tuna']
};

function updateBoatPosition() {
    boat.style.left = boatX + 'px';
    boat.style.top = boatY + 'px';
    updateThrowBaitArea();
}

function updateThrowBaitArea() {
    throwBaitArea.style.left = (boatX - 130) + 'px';
    throwBaitArea.style.top = (boatY - 120) + 'px';
}

function moveBoat(direction) {
    const step = 10;
    switch (direction) {
        case 'left':
            boatX = Math.max(0, boatX - step);
            break;
        case 'right':
            boatX = Math.min(360, boatX + step);
            break;
        case 'up':
            boatY = Math.max(0, boatY - step);
            break;
        case 'down':
            boatY = Math.min(340, boatY + step);
            break;
    }
    updateBoatPosition();
}

document.getElementById('moveLeft').addEventListener('click', () => moveBoat('left'));
document.getElementById('moveRight').addEventListener('click', () => moveBoat('right'));
document.getElementById('moveUp').addEventListener('click', () => moveBoat('up'));
document.getElementById('moveDown').addEventListener('click', () => moveBoat('down'));

throwBaitArea.addEventListener('click', (e) => {
    if (isFishing) return;

    const rect = throwBaitArea.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    throwBait(x, y);
});

function throwBait(x, y) {
    isFishing = true;
    bait.style.display = 'block';
    bait.style.left = (boatX + 15) + 'px';
    bait.style.top = (boatY + 30) + 'px';

    const targetX = boatX + x - 150;
    const targetY = boatY + y - 150;

    animateBait(targetX, targetY);
}

function animateBait(targetX, targetY) {
    const startX = parseInt(bait.style.left);
    const startY = parseInt(bait.style.top);
    const dx = targetX - startX;
    const dy = targetY - startY;
    const distance = Math.sqrt(dx * dx + dy * dy);
    const duration = distance * 5;

    let start;
    function step(timestamp) {
        if (!start) start = timestamp;
        const progress = (timestamp - start) / duration;

        if (progress < 1) {
            bait.style.left = (startX + dx * progress) + 'px';
            bait.style.top = (startY + dy * progress) + 'px';
            requestAnimationFrame(step);
        } else {
            bait.style.left = targetX + 'px';
            bait.style.top = targetY + 'px';
            updateStatus('Waiting for fish...');
            waitForFish();
        }
    }
    requestAnimationFrame(step);
}

function waitForFish() {
    setTimeout(() => {
        if (Math.random() < 0.7) {
            fishNibble();
        } else {
            resetFishing();
            updateStatus('No bite. Try again!');
        }
    }, 2000 + Math.random() * 3000);
}

function fishNibble() {
    updateStatus('Fish nibbling!');
    const nearestFish = findNearestFish();
    if (nearestFish) {
        moveFishToBait(nearestFish);
        hookedFish = nearestFish;
    }

    setTimeout(() => {
        if (Math.random() < 0.5) {
            hookFish();
        } else {
            resetFishing();
            updateStatus('Fish escaped. Try again!');
        }
    }, 1000);
}

function hookFish() {
    updateStatus('Fish hooked! Reeling in...');
    pullFish();
}

function pullFish() {
    const startX = parseInt(bait.style.left);
    const startY = parseInt(bait.style.top);
    const targetX = boatX + 15;
    const targetY = boatY + 30;

    let start;
    function step(timestamp) {
        if (!start) start = timestamp;
        const progress = (timestamp - start) / 1000;

        if (progress < 1) {
            const newX = startX + (targetX - startX) * progress;
            const newY = startY + (targetY - startY) * progress;
            bait.style.left = newX + 'px';
            bait.style.top = newY + 'px';
            if (hookedFish) {
                hookedFish.style.left = newX + 'px';
                hookedFish.style.top = newY + 'px';
            }
            requestAnimationFrame(step);
        } else {
            const caughtFishType = fishTypes[weather][Math.floor(Math.random() * fishTypes[weather].length)];
            caughtFish.push(caughtFishType);
            updateStatus(`You caught a ${caughtFishType}!`);
            setTimeout(() => {
                resetFishing();
                updateStatus('');
            }, 2000);
        }
    }
    requestAnimationFrame(step);
}

function resetFishing() {
    isFishing = false;
    bait.style.display = 'none';
    if (hookedFish) {
        despawnFish(hookedFish);
        hookedFish = null;
    }
}

function updateStatus(message) {
    statusDisplay.textContent = message;
}

function spawnFishShadow() {
    if (fishShadows.length >= 10) return;

    const fish = document.createElement('div');
    fish.className = 'fish';
    fish.style.left = Math.random() * 370 + 'px';
    fish.style.top = Math.random() * 370 + 'px';
    gameArea.appendChild(fish);
    fishShadows.push(fish);
    
    setTimeout(() => {
        fish.style.opacity = '1';
    }, 50);

    swimRandomly(fish);
}

function swimRandomly(fish) {
    function swim() {
        const targetX = Math.random() * 370;
        const targetY = Math.random() * 370;
        
        let collision = false;
        do {
            collision = false;
            for (let otherFish of fishShadows) {
                if (otherFish !== fish) {
                    const dx = targetX - parseInt(otherFish.style.left);
                    const dy = targetY - parseInt(otherFish.style.top);
                    const distance = Math.sqrt(dx * dx + dy * dy);
                    if (distance < 50) {
                        collision = true;
                        break;
                    }
                }
            }
            if (collision) {
                targetX = Math.random() * 370;
                targetY = Math.random() * 370;
            }
        } while (collision);

        fish.style.left = targetX + 'px';
        fish.style.top = targetY + 'px';

        setTimeout(swim, Math.random() * 5000 + 5000);
    }
    swim();
}

function manageFishPopulation() {
    setInterval(() => {
        if (Math.random() < 0.3 && fishShadows.length < 10) {
            spawnFishShadow();
        } else if (Math.random() < 0.2 && fishShadows.length > 0) {
            const fishToRemove = fishShadows[Math.floor(Math.random() * fishShadows.length)];
            despawnFish(fishToRemove);
        }
    }, 3000);
}

function despawnFish(fish) {
    fish.style.opacity = '0';
    setTimeout(() => {
        gameArea.removeChild(fish);
        fishShadows = fishShadows.filter(f => f !== fish);
    }, 1000);
}

function findNearestFish() {
    const baitX = parseInt(bait.style.left);
    const baitY = parseInt(bait.style.top);
    let nearestFish = null;
    let minDistance = Infinity;

    fishShadows.forEach(fish => {
        const fishX = parseInt(fish.style.left);
        const fishY = parseInt(fish.style.top);
        const distance = Math.sqrt((fishX - baitX) ** 2 + (fishY - baitY) ** 2);

        if (distance < minDistance) {
            minDistance = distance;
            nearestFish = fish;
        }
    });

    return nearestFish;
}

function moveFishToBait(fish) {
    const baitX = parseInt(bait.style.left);
    const baitY = parseInt(bait.style.top);
    fish.style.left = baitX + 'px';
    fish.style.top = baitY + 'px';
}

function updateGameInfo() {
    gameInfoDisplay.textContent = `Money: $${money} | Time: ${Math.floor(gameTime / 60)}:${(gameTime % 60).toString().padStart(2, '0')} | Weather: ${weather}`;
}

function changeWeather() {
    const weathers = ['sunny', 'rainy', 'cloudy'];
    weather = weathers[Math.floor(Math.random() * weathers.length)];
    updateGameInfo();
}

function startGame() {
    updateBoatPosition();
    manageFishPopulation();
    setInterval(() => {
        gameTime++;
        if (gameTime % 300 === 0) {
            changeWeather();
        }
        updateGameInfo();
    }, 1000);
}

openMenuBtn.addEventListener('click', () => {
    modal.style.display = 'block';
    updateCaughtFishList();
});

closeModal.addEventListener('click', () => {
    modal.style.display = 'none';
});

window.addEventListener('click', (event) => {
    if (event.target === modal) {
        modal.style.display = 'none';
    }
});

baitSelect.addEventListener('change', (e) => {
    selectedBait = e.target.value;
});

function updateCaughtFishList() {
    caughtFishList.innerHTML = '';
    const fishCount = {};
    caughtFish.forEach(fish => {
        if (fishCount[fish]) {
            fishCount[fish]++;
        } else {
            fishCount[fish] = 1;
        }
    });
    for (const [fish, count] of Object.entries(fishCount)) {
        const li = document.createElement('li');
        li.textContent = `${fish}: ${count}`;
        caughtFishList.appendChild(li);
    }
}

sellFishBtn.addEventListener('click', () => {
    let earnings = 0;
    caughtFish.forEach(fish => {
        earnings += Math.floor(Math.random() * 10) + 1;
    });
    money += earnings;
    caughtFish = [];
    updateCaughtFishList();
    updateGameInfo();
    alert(`You earned $${earnings} from selling your fish!`);
});

startGame();