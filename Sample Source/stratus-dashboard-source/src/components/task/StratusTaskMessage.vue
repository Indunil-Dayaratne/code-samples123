<template>
    <span v-b-popover.hover.top="overallStringValue">
        <span v-for="(val, idx) in valuesArray" :key="idx">
            <template v-if="val.type === 'text'">
                {{ val.value }}
            </template>
            <template v-else-if="val.type === 'link'">
                <span class="message-link" @click="navigateLink(val.value)">{{val.stringValue}}</span>
            </template>
        </span>
    </span>
</template>

<script>
import api from '../../shared/api';
    export default {
        name: 'StratusTaskMessage',
        props: {
            message: {
                type: String,
                default: ''
            }
        },
        data() {
            return {
                linkRegExp: /\(.*\)\[\S*\]/g,
                token: ''
            }
        },
        computed: {
            valuesArray() {
                const output = [];
                const splits = this.message.split(this.linkRegExp);
                const matches = this.message.match(this.linkRegExp);
                for (let i = 0; i < splits.length; i++) {
                    const split = splits[i];
                    output.push({
                        type: 'text',
                        value: split,
                        stringValue: split
                    });
                    if(matches && i < matches.length) {
                        const linkStart = matches[i].indexOf('[');
                        output.push({
                            type: 'link',
                            value: matches[i].substring(linkStart + 1, matches[i].length - 1), 
                            stringValue: matches[i].substring(1, linkStart - 1)
                        });
                    }
                }
                return output;
            },
            overallStringValue() {
                return this.valuesArray && this.valuesArray.length > 0 
                    ? this.valuesArray.map(x => x.stringValue).join('')
                    : '';
            }
        },
        methods: {
            navigateLink(link){
                api.navigateWithToken(link);
            }
        }
    }
</script>

<style lang="scss" scoped>
.message-link {
    color: #20a8d8;
    text-decoration: none;
    background-color: transparent;

    &:hover {
        color: #167495;
        text-decoration: underline;
        cursor: pointer;
    }
}
</style>