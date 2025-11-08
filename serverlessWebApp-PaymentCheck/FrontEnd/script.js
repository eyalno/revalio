const API_URL = "https://yuedw9yzch.execute-api.us-east-2.amazonaws.com/dev/login";

document.getElementById("loginForm").addEventListener("submit", async (e) => {
  e.preventDefault();
  const username = document.getElementById("username").value;
  const password = document.getElementById("password").value;

  const res = await fetch(API_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, password }),
  });

  const data = await res.json();

  if (data.status === "ok") alert("Welcome!");
  else if (data.status === "expired") alert("Payment expired");
  else alert("Invalid credentials");
});