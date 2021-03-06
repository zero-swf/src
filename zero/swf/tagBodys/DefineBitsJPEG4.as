/***
DefineBitsJPEG4
创建人：ZЁЯ¤　身高：168cm+；体重：57kg+；未婚（已有女友）；最爱的运动：睡觉；格言：路见不平，拔腿就跑。QQ：358315553。
创建时间：2011年08月29日 15:37:22（代码生成器 V2.0.0 F:/airs/program files2/CodesGenerater2/bin-debug/CodesGenerater2.swf）
简要说明：这家伙很懒什么都没写。
用法举例：这家伙还是很懒什么都没写。
*/

//This tag defines a bitmap character with JPEG compression. This tag extends
//DefineBitsJPEG3, adding a deblocking parameter. While this tag also supports PNG and
//GIF89a data, the deblocking filter (和 cs4 里的 "启用jpeg解块"有关?) is not applied to such data.
//The minimum file format version for this tag is SWF 10.
//
//DefineBitsJPEG4
//Field 				Type 					Comment
//Header 				RECORDHEADER (long) 	Tag type = 90.
//CharacterID 			UI16 					ID for this character.
//AlphaDataOffset 		UI32 					Count of bytes in ImageData.
//DeblockParam 			UI16 					Parameter to be fed into the deblocking filter. The parameter describes a relative strength of the deblocking filter from 0-100% expressed in a normalized 8.8 fixed point format.
//ImageData 			UI8[data size] 			Compressed image data in either JPEG, PNG, or GIF89a format.
//BitmapAlphaData 		UI8[alpha data size] 	ZLIB compressed array of alpha data. Only supported when tag contains JPEG data. One byte per pixel. Total size after decompression must equal (width * height) of JPEG image.

package zero.swf.tagBodys{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	
	import zero.swf.BytesData;
	
	public class DefineBitsJPEG4{
		
		public var id:int;//UI16
		public var DeblockParam:Number;//FIXED8
		public var ImageData:BytesData;
		public var BitmapAlphaData:BytesData;
		
		public function DefineBitsJPEG4(){
			//id=0;
			//DeblockParam=NaN;
			//ImageData=null;
			//BitmapAlphaData=null;
		}
		
		public function initByData(data:ByteArray,offset:int,endOffset:int,_initByDataOptions:Object):int{
			
			id=data[offset++]|(data[offset++]<<8);
			
			var AlphaDataOffset:uint=data[offset++]|(data[offset++]<<8)|(data[offset++]<<16)|(data[offset++]<<24);
			
			DeblockParam=data[offset++]/256+data[offset++];
			
			ImageData=new BytesData();
			offset=ImageData.initByData(data,offset,offset+AlphaDataOffset-2,_initByDataOptions);
			
			BitmapAlphaData=new BytesData();
			return BitmapAlphaData.initByData(data,offset,endOffset,_initByDataOptions);
			
		}
		public function toData(_toDataOptions:Object):ByteArray{
			
			var data:ByteArray=new ByteArray();
			
			data[0]=id;
			data[1]=id>>8;
			
			var AlphaDataOffset:int=ImageData.dataLength+2;
			
			data[2]=AlphaDataOffset;
			data[3]=AlphaDataOffset>>8;
			data[4]=AlphaDataOffset>>16;
			data[5]=AlphaDataOffset>>24;
			
			data[6]=DeblockParam*256;
			data[7]=DeblockParam;
			
			data.position=8;
			data.writeBytes(ImageData.toData(_toDataOptions));
			
			data.writeBytes(BitmapAlphaData.toData(_toDataOptions));
			
			return data;
			
		}
		
		//20120724
		/**
		 * 
		 * 获取图片数据
		 * 可能是 JPG，PNG，GIF 等
		 * 如果是 JPG 将不带透明数据，需要调用 getPNGData()
		 * 
		 */
		public function getImgData():ByteArray{
			if(ImageData){
				var imgData:ByteArray=ImageData.toData(null);
				var offset:int=0;
				var endOffset:int=imgData.length;
				var jpgData:ByteArray=new ByteArray();
				jpgData[0]=0xff;
				jpgData[1]=0xd8;
				jpgData.position=2;
				while(offset<endOffset){
					var blockStartOffset:int=offset;
					if(imgData[offset]==0xff){
						while(imgData[++offset]==0xff){}
						switch(imgData[offset++]){
							case 0xd8:
								//图像开始SOI(Start of Image)标记
							break;
							case 0xd9:
								//图像结束EOI(End of Image)
							break;
							case 0xda:
								//扫描开始SOS(Start of Scan)
								jpgData.writeBytes(imgData,blockStartOffset);
								return jpgData;
							break;
							default:
								var blockSize:int=(imgData[offset++]<<8)|imgData[offset++];
								offset+=blockSize-2;
								jpgData.writeBytes(imgData,blockStartOffset,offset-blockStartOffset);
							break;
						}
					}else{
						trace("imgData[offset]="+imgData[offset]);
						return imgData;//可能是 PNG 或 GIF
					}
				}
				throw new Error("找不到扫描开始标记ffda");
			}
			throw new Error("请先调用 initByData() 或 initByXML() 进行初始化");
		}
		public function applyBitmapAlpha(jpgBmd:BitmapData):BitmapData{//20140724
			
			var alphaBytes:ByteArray=BitmapAlphaData.toData(null);
			alphaBytes.uncompress();
			
			var imgBytes:ByteArray=jpgBmd.getPixels(jpgBmd.rect);
			var i:int=alphaBytes.length;
			
			while(--i>=0){
				switch(alphaBytes[i]){//alpha
					case 0xff:
					break;
					case 0x00:
						imgBytes[i*4]=0x00;
						imgBytes[i*4+1]=0x00;
						imgBytes[i*4+2]=0x00;
						imgBytes[i*4+3]=0x00;
					break;
					default:
						imgBytes[i*4]=alphaBytes[i];
						var k:Number=0xff/alphaBytes[i];
						var colorxx:int=imgBytes[i*4+1]*k;
						if(colorxx<0xff){
							imgBytes[i*4+1]=colorxx;
						}else{
							imgBytes[i*4+1]=0xff;
						}
						colorxx=imgBytes[i*4+2]*k;
						if(colorxx<0xff){
							imgBytes[i*4+2]=colorxx;
						}else{
							imgBytes[i*4+2]=0xff;
						}
						colorxx=imgBytes[i*4+3]*k;
						if(colorxx<0xff){
							imgBytes[i*4+3]=colorxx;
						}else{
							imgBytes[i*4+3]=0xff;
						}
					break;
				}
			}
			
			var pngBmd:BitmapData=new BitmapData(jpgBmd.width,jpgBmd.height,true,0x00000000);
			imgBytes.position=0;
			pngBmd.setPixels(pngBmd.rect,imgBytes);
			
			return pngBmd;
			
		}
		public function getPNGData(jpegDecoder:Object,pngEncoder:Object=null):ByteArray{
			var imgData:ByteArray=getImgData();
			if(imgData[0]==0xff){
				
				var jpgBmd:BitmapData=jpegDecoder.decode(imgData);
				
				var pngBmd:BitmapData=applyBitmapAlpha(jpgBmd);
				
				jpgBmd.dispose();
				
				if(pngEncoder){
					return pngEncoder.encode(pngBmd);
				}
				if(pngBmd.hasOwnProperty("encode")){
					return pngBmd["encode"](pngBmd.rect,new (getDefinitionByName("flash.display.PNGEncoderOptions"))());
				}
				throw new Error("请传入 pngEncoder，或添加编译器参数：-swf-version 16（>=16）使支持 BitmapData.encode");
			}
			return imgData;
		}
		
		/*20140725 好像有时候宽高会反过来
		public function getJPGWH():Array{
			if(ImageData){
				var imgData:ByteArray=ImageData.toData(null);
				var offset:int=0;
				var endOffset:int=imgData.length;
				while(offset<endOffset){
					var blockStartOffset:int=offset;
					if(imgData[offset]==0xff){
						while(imgData[++offset]==0xff){}
						switch(imgData[offset++]){
							case 0xd8:
								//图像开始SOI(Start of Image)标记
							break;
							case 0xd9:
								//图像结束EOI(End of Image)
							break;
							case 0xc0:
								return [
									(imgData[offset+3]<<8)|imgData[offset+4],
									(imgData[offset+5]<<8)|imgData[offset+6]
								];
							break;
							case 0xda:
								//扫描开始SOS(Start of Scan)
								throw new Error("找不到标记ffc0");
							break;
							default:
								var blockSize:int=(imgData[offset++]<<8)|imgData[offset++];
								offset+=blockSize-2;
							break;
						}
					}else{
						trace("imgData[offset]="+imgData[offset]);
						throw new Error("不是 JPEG");
					}
				}
				throw new Error("找不到扫描开始标记ffda");
			}
			throw new Error("请先调用 initByData() 或 initByXML() 进行初始化");
		}*/
		
		/**
		 * 
		 * 同步解码为 BitmapData
		 * decoder 可以是 http://code.google.com/p/as3-jpeg-decoder/downloads/detail?name=jpeg-decoder.zip&can=2&q= 里的 JPEGDecoder
		 * 使用方法：
		 *  var jpegDecoder:Object={decode:function(imgData:ByteArray):BitmapData{
		 *		return new JPEGDecoder().parseAsBitmapData(imgData);//未考虑 imgData 可能是 PNG 或 GIF 的情况
		 *	}};
		 *  defineBitsJPEG2.decode(jpegDecoder);
		 * 
		 */
		public function decode(decoder:Object):BitmapData{
			if(ImageData){
				return decoder.decode(getImgData());
			}
			throw new Error("请先调用 initByData() 或 initByXML() 进行初始化");
		}
		
		private var loader:Loader;
		private var onDecodeComplete:Function;
		/**
		 * 
		 * 异步解码为 BitmapData
		 */
		public function decodeAsync(_onDecodeComplete:Function):void{
			if(ImageData){
				onDecodeComplete=_onDecodeComplete;
				
				var swfData:ByteArray=new ByteArray();
				
				swfData[0]=0x46;
				swfData[1]=0x57;
				swfData[2]=0x53;
				
				swfData[3]=0x09;
				
				swfData[8]=0x30;
				swfData[9]=0x0a;
				swfData[10]=0x00;
				swfData[11]=0xa0;
				
				swfData[12]=0x00;
				swfData[13]=0x01;
				
				swfData[14]=0x01;
				swfData[15]=0x00;
				
				//<FileAttributes class="zero.swf.tagBodys.FileAttributes" UseGPU="false" UseDirectBlit="false" HasMetadata="false" ActionScript3="true" suppressCrossDomainCaching="false" swfRelativeUrls="false" UseNetwork="false"/>
				swfData[16]=0x44;
				swfData[17]=0x11;
				swfData[18]=0x08;
				swfData[19]=0x00;
				swfData[20]=0x00;
				swfData[21]=0x00;
				
				//<SetBackgroundColor class="zero.swf.tagBodys.SetBackgroundColor" BackgroundColor="0x000000"/>
				swfData[22]=0x43;
				swfData[23]=0x02;
				swfData[24]=0x00;
				swfData[25]=0x00;
				swfData[26]=0x00;
				
				//DefineBitsJPEG4
				swfData[27]=0xbf;
				swfData[28]=0x16;
				var thisData:ByteArray=this.toData(null);
				var thisDataSize:int=thisData.length;
				swfData[29]=thisDataSize;
				swfData[30]=thisDataSize>>8;
				swfData[31]=thisDataSize>>16;
				swfData[32]=thisDataSize>>24;
				swfData.position=33;
				swfData.writeBytes(thisData);
				
				//<PlaceObject3 class="zero.swf.tagBodys.PlaceObject3" PlaceFlagMove="false" PlaceFlagHasImage="true" Depth="1" CharacterId="1"/>
				swfData[swfData.length]=0x86;
				swfData[swfData.length]=0x11;
				swfData[swfData.length]=0x02;
				swfData[swfData.length]=0x10;
				swfData[swfData.length]=0x01;
				swfData[swfData.length]=0x00;
				swfData[swfData.length]=id;
				swfData[swfData.length]=id>>8;
				
				//<ShowFrame frame="1"/>
				swfData[swfData.length]=0x40;
				swfData[swfData.length]=0x00;
				
				//<End/>
				swfData[swfData.length]=0x00;
				swfData[swfData.length]=0x00;
				
				var swfDataSize:int=swfData.length;
				swfData[4]=swfDataSize;
				swfData[5]=swfDataSize>>8;
				swfData[6]=swfDataSize>>16;
				swfData[7]=swfDataSize>>24;
				
				loader=new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,decodeComplete);
				var loaderContext:LoaderContext=new LoaderContext();
				if(loaderContext.hasOwnProperty("allowCodeImport")){
					loaderContext["allowCodeImport"]=true;
					loader.loadBytes(swfData,loaderContext);
				}else{
					loader.loadBytes(swfData);
				}
			}else{
				throw new Error("请先调用 initByData() 或 initByXML() 进行初始化");
			}
		}
		private function decodeComplete(...args):void{
			var bmd:BitmapData=((loader.content as Sprite).getChildAt(0) as Bitmap).bitmapData;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,decodeComplete);
			loader.unloadAndStop();
			loader=null;
			if(onDecodeComplete==null){
			}else{
				var _onDecodeComplete:Function=onDecodeComplete;
				onDecodeComplete=null;
				_onDecodeComplete(bmd);
			}
		}
		
		//CONFIG::USE_XML{
			public function toXML(xmlName:String,_toXMLOptions:Object):XML{
				
				var xml:XML=<{xmlName} class="zero.swf.tagBodys.DefineBitsJPEG4"
					id={id}
					DeblockParam={DeblockParam}
				/>;
				
				xml.appendChild(ImageData.toXML("ImageData",_toXMLOptions));
				
				xml.appendChild(BitmapAlphaData.toXML("BitmapAlphaData",_toXMLOptions));
				
				return xml;
				
			}
			public function zhinengToXML(xmlName:String,_toXMLOptions:Object):XML{
				
				var imgData:ByteArray=getPNGData(_toXMLOptions.jpegDecoder,_toXMLOptions.pngEncoder);
				
				var src:String=_toXMLOptions.saveData("图片",this,id,imgData,"png");
				
				return <DefineBitsJPEG2 class="zero.swf.tagBodys.DefineBitsJPEG2"
						id={id}
					>
						<ImageData class="zero.swf.BytesData"
							src={src}
						/>
					</DefineBitsJPEG2>;
				
			}
			public function initByXML(xml:XML,_initByXMLOptions:Object):void{
				
				id=int(xml.@id.toString());
				
				DeblockParam=Number(xml.@DeblockParam.toString());
				
				ImageData=new BytesData();
				ImageData.initByXML(xml.ImageData[0],_initByXMLOptions);
				
				BitmapAlphaData=new BytesData();
				BitmapAlphaData.initByXML(xml.BitmapAlphaData[0],_initByXMLOptions);
				
			}
		//}//end of CONFIG::USE_XML
	}
}