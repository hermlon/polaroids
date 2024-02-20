let Hooks = {}

Hooks.ImageLoad = {
    mounted() {
        console.log(this.el)
        if (this.el.previousElementSibling == null) {
            this.el.classList.add("opacity-0")
            setTimeout(() => {
                this.el.classList.remove("opacity-0")
            }, 400)
        }
    }
}

Hooks.ImageShare = {
    mounted() {
        //const node = document.createElement("img")
        //node.setAttribute("src", "https://r2.yuustan.space/cute/06ed6e9b-7baf-4e61-8929-f481d7f81ef0.jpg")
        //this.el.appendChild(node)
        this.handleEvent("share", async ({ image }) => {
            console.log(image)
            //const response = await fetch("https://r2.yuustan.space/cute/06ed6e9b-7baf-4e61-8929-f481d7f81ef0.jpg", { cache: "default" })
            const response = await fetch(image, { cache: "default" })
            //const response = await fetch(image, { cache: "default" })
            console.log("got image")
            console.log(response)
            const fileBinary = await response.blob()
            const files = [
                new File([fileBinary], "filename.jpeg", {
                    type: fileBinary.type,//'image/jpeg',
                    lastModified: new Date().getTime(),
                })
            ]
            const share = {
                        files,
                        title: "this is a title",
                        text: "Beautiful images"
            }
                try {
                    await navigator.share(share);
                    console.log("Shared!")
                } catch (error) {
                    console.log(`Error: ${error.message}`)
                }
        })
    }
}

export { Hooks }