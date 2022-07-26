const submitButtonEl = document.getElementById('submit');
const inputMessageEl = document.getElementById('input');
const rawMessageEl = document.getElementById('rawMessage');
const signedMessageEl = document.getElementById('signedMessage');

submitButtonEl.addEventListener('click', (_) => {
    const message = inputMessageEl.value;
    rawMessageEl.innerText = 'Raw message: ' + message;

    const signedMessage = message;
    signedMessageEl.innerText = 'Signed message: ' + signedMessage;
});